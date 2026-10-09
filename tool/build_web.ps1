$envFile = "$PSScriptRoot\local_env.json"
if (Test-Path $envFile) {
    $envData = Get-Content $envFile -Raw | ConvertFrom-Json
    flutter build web --release `
        --dart-define=SUPABASE_URL="$($envData.SUPABASE_URL)" `
        --dart-define=SUPABASE_ANON_KEY="$($envData.SUPABASE_ANON_KEY)" `
        --dart-define=ENVIRONMENT="$($envData.ENVIRONMENT)"
} else {
    flutter build web --release
}
