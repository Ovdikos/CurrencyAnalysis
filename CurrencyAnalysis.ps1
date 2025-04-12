$apiUrl = "https://api.privatbank.ua/p24api/pubinfo?exchange&coursid=5"
$response = Invoke-RestMethod -Uri $apiUrl

$usdRate = ($response | Where-Object { $_.ccy -eq "USD" }).buy
$eurRate = ($response | Where-Object { $_.ccy -eq "EUR" }).buy

$csvPath = "currency_history.csv"
$currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

[PSCustomObject]@{
    DateTime = $currentDate
    USD      = $usdRate
    EUR      = $eurRate
} | Export-Csv -Path $csvPath -Append -NoTypeInformation

Write-Host "You saved data in: $csvPath "

$history = Import-Csv -Path $csvPath

$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Сurrency exchange rates</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { 
            font-family: Arial; 
            padding: 20px; 
            background: #f0f0f0;
        }
        .chart-box {
            background: white;
            border-radius: 10px;
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="chart-box">
        <canvas id="currencyChart"></canvas>
    </div>

    <script>
        const data = {
            labels: [$( ($history.DateTime | ForEach-Object { "'$_'" }) -join "," )],
            datasets: [
                {
                    label: 'USD',
                    data: [$( $history.USD -join "," )],
                    borderColor: '#2196F3',
                    tension: 0.1
                },
                {
                    label: 'EUR',
                    data: [$( $history.EUR -join "," )],
                    borderColor: '#4CAF50',
                    tension: 0.1
                }
            ]
        };

        const config = {
            type: 'line',
            data: data,
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: 'Сurrency exchange rate (USD/EUR)'
                    }
                }
            }
        };

        new Chart(document.getElementById('currencyChart'), config);
    </script>
</body>
</html>
"@

$htmlContent | Out-File -FilePath "index.html"
Write-Host "Plot saved to index.html"


$From = "your mail"
$To = "someone mail"
$Attachment = "index.hmtl location"
$Subject = "Raport"
$Body = "<h2>Check the raport</h>"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment
Write-Host "Mail was sent"