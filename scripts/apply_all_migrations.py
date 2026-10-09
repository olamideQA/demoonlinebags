import urllib.request
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

PROJECT_REF = os.environ.get('SUPABASE_PROJECT_REF', 'htvcavnqsgyjrbtqefxk')
MGMT_TOKEN = os.environ.get('SUPABASE_MGMT_TOKEN', '')
QUERY_URL = f'https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query'

def run_sql(query_str):
    headers = {
        'Authorization': f'Bearer {MGMT_TOKEN}',
        'Content-Type': 'application/json'
    }
    body = json.dumps({'query': query_str}).encode('utf-8')
    req = urllib.request.Request(QUERY_URL, data=body, headers=headers, method='POST')
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = resp.read().decode('utf-8')
            return json.loads(data) if data else []
    except urllib.error.HTTPError as e:
        err = e.read().decode('utf-8')
        print(f"Error ({e.code}): {err}")
        raise Exception(err)

def clean_sql(sql_content):
    # Remove full-line comments and split into individual executable statements
    lines = []
    for line in sql_content.splitlines():
        trimmed = line.strip()
        if trimmed.startswith('--'):
            continue
        lines.append(line)
    
    cleaned = "\n".join(lines)
    # Split by semicolon
    raw_statements = cleaned.split(';')
    valid_statements = []
    for s in raw_statements:
        st = s.strip()
        if len(st) > 4:
            valid_statements.append(st)
    return valid_statements

def main():
    print("=== EXECUTING DEMO ONLINE BAGS COMPLETE MIGRATION & SEEDING ===")
    sql_path = os.path.join(os.path.dirname(__file__), '..', 'supabase', 'run_all_migrations.sql')
    with open(sql_path, 'r', encoding='utf-8') as f:
        sql = f.read()

    statements = clean_sql(sql)
    print(f"Found {len(statements)} clean SQL statements to execute.")

    for i, stmt in enumerate(statements):
        first_line = stmt.strip().splitlines()[0][:50]
        try:
            run_sql(stmt)
            print(f"  [{i+1}/{len(statements)}] OK: {first_line}")
        except Exception as e:
            print(f"  [{i+1}/{len(statements)}] FAILED: {first_line} -> {e}")

    # Verify Tables & Counts
    print("\n=== VERIFYING TABLES & LIVE RECORDS IN SUPABASE ===")
    for table in ['categories', 'collections', 'products', 'product_variants', 'pairings', 'reviews', 'banners']:
        try:
            count_res = run_sql(f"SELECT COUNT(*) as count FROM public.{table};")
            count = count_res[0]['count']
            print(f"  Table public.{table}: {count} records")
        except Exception as e:
            print(f"  Table public.{table}: query failed ({e})")

if __name__ == '__main__':
    main()
