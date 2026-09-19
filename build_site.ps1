$siteDir = "C:\Users\shaza\.gemini\antigravity\scratch\aitechhorizon"

# 1. Get all dated articles
$files = Get-ChildItem -Path $siteDir -Filter "*.html" | Where-Object {
    $_.Name -match '^\d{2}-[A-Za-z]{3}-\d{4}'
}

# Parse dates and sort descending
$articles = @()
foreach ($f in $files) {
    if ($f.Name -match '^(\d{2})-([A-Za-z]{3})-(\d{4})') {
        $day = [int]$matches[1]
        $monthStr = $matches[2]
        $year = [int]$matches[3]
        $dateStr = "$day-$monthStr-$year"
        $dateObj = [DateTime]::ParseExact($dateStr, "d-MMM-yyyy", [System.Globalization.CultureInfo]::InvariantCulture)

        $content = Get-Content $f.FullName -Raw
        
        $title = ""
        if ($content -match '<h1[^>]*>(.*?)</h1>') { 
            $title = $matches[1].Trim() 
        } else {
            $title = $f.BaseName
        }

        $excerpt = ""
        if ($content -match '<meta name="description" content="(.*?)"') {
            $excerpt = $matches[1].Trim()
        } elseif ($content -match '<p class="lead"[^>]*>(.*?)</p>') {
            $excerpt = $matches[1].Trim()
        } elseif ($content -match '<p[^>]*>(.*?)</p>') {
            $excerpt = ($matches[1] -replace '<[^>]+>', '').Trim()
            if ($excerpt.Length -gt 150) { $excerpt = $excerpt.Substring(0, 147) + "..." }
        }
        if ([string]::IsNullOrWhiteSpace($excerpt)) {
            $excerpt = "A comprehensive analysis and practical guide to $title."
        }

        $category = "AI Tools"
        if ($f.Name -match "money|earn|freelanc|crypto|dropshipping|etsy|business") {
            $category = "Make Money"
        } elseif ($f.Name -match "coding|claude|chatgpt-vs|dev") {
            $category = "AI Tools"
        } elseif ($f.Name -match "audio|music|voice|avatar|video|tiktok") {
            $category = "AI Media"
        } elseif ($f.Name -match "essay|thesis|note|education|student|language") {
            $category = "Productivity"
        }

        # Select Image
        $img = "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=600&q=80"
        if ($category -eq "Make Money") {
            $img = "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?auto=format&fit=crop&w=600&q=80"
        } elseif ($category -eq "AI Media") {
            $img = "https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?auto=format&fit=crop&w=600&q=80"
        } elseif ($f.Name -match "music|audio") {
            $img = "https://images.unsplash.com/photo-1511379938547-c1f69419868d?auto=format&fit=crop&w=600&q=80"
        } elseif ($f.Name -match "note|write|essay") {
            $img = "https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=600&q=80"
        } elseif ($f.Name -match "health") {
            $img = "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=600&q=80"
        } elseif ($f.Name -match "data|automat") {
            $img = "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=600&q=80"
        }

        $articles += [PSCustomObject]@{
            File = $f.Name
            Date = $dateObj
            DateDisplay = $dateObj.ToString("MMM dd, yyyy")
            Title = $title
            Excerpt = $excerpt
            Category = $category
            Image = $img
        }
    }
}

# Sort descending by date, then by filename
$sortedArticles = $articles | Sort-Object -Property @{Expression="Date"; Descending=$true}, @{Expression="File"; Descending=$true}

Write-Output "Found $($sortedArticles.Count) dated articles."

# 2. Build Hero Slider (Top 6 latest)
$sliderArticles = $sortedArticles | Select-Object -First 6
$slidesHtml = ""
for ($i = 0; $i -lt $sliderArticles.Count; $i++) {
    $art = $sliderArticles[$i]
    $activeClass = if ($i -eq 0) { "slide active" } else { "slide" }
    $slideImg = $art.Image -replace "w=600", "w=1200"
    $slidesHtml += @"
        <!-- Slide $($i + 1) ($($art.DateDisplay)) -->
        <div class="$activeClass">
            <img src="$slideImg" alt="$($art.Title)">
            <div class="slide-content">
                <h1>$($art.Title)</h1>
                <p>$($art.Excerpt)</p>
                <a href="$($art.File)" class="btn">Read Article</a>
            </div>
        </div>
"@ + "`n"
}

# 3. Build Blog Grid
$gridHtml = ""
$counter = $sortedArticles.Count
foreach ($art in $sortedArticles) {
    $gridHtml += @"
            <!-- Article $counter -->
            <a href="$($art.File)" class="card">
                <div class="card-img">
                    <img src="$($art.Image)" alt="$($art.Title)">
                </div>
                <div class="card-content">
                    <span class="category">$($art.Category)</span>
                    <h3 class="card-title">$($art.Title)</h3>
                    <p class="card-excerpt">$($art.Excerpt)</p>
                    <div class="card-footer">
                        <span>$($art.DateDisplay)</span>
                        <span class="read-more">Read More &rarr;</span>
                    </div>
                </div>
            </a>
"@ + "`n"
    $counter--
}

# 4. Update index.html
$indexPath = "$siteDir\index.html"
$indexContent = Get-Content $indexPath -Raw

# Replace slider
$sliderRegex = '(?s)<div class="slider">[\s\S]*?</div>\s*<!-- Slider Navigation Controls -->'
$newSliderBlock = "<div class=`"slider`">`n$slidesHtml    </div>`n`n        <!-- Slider Navigation Controls -->"
$indexContent = $indexContent -replace $sliderRegex, $newSliderBlock

# Replace blog-grid
$gridRegex = '(?s)<div class="blog-grid">[\s\S]*?</div>\s*<!-- AdSense Placeholder -->'
$newGridBlock = "<div class=`"blog-grid`">`n$gridHtml        </div>`n`n        <!-- AdSense Placeholder -->"
$indexContent = $indexContent -replace $gridRegex, $newGridBlock

Set-Content -Path $indexPath -Value $indexContent -Encoding utf8
Write-Output "Updated index.html slider and blog grid successfully."

# 5. Update sitemap.xml
$allHtmlFiles = Get-ChildItem -Path $siteDir -Filter "*.html" | Sort-Object Name
$sitemapXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
"@ + "`n"

# Add home and main pages first
$priorityPages = @("index.html", "about.html", "contact.html", "ai-tools.html", "make-money.html", "privacy-policy.html", "terms.html", "disclaimer.html")
foreach ($p in $priorityPages) {
    $pPath = "$siteDir\$p"
    if (Test-Path $pPath) {
        $prio = if ($p -eq "index.html") { "1.0" } else { "0.9" }
        $sitemapXml += @"
  <url>
    <loc>https://aitechhorizon.online/$p</loc>
    <lastmod>2026-09-19</lastmod>
    <priority>$prio</priority>
  </url>
"@ + "`n"
    }
}

# Add all articles
foreach ($hf in $allHtmlFiles) {
    if ($priorityPages -contains $hf.Name) { continue }
    $sitemapXml += @"
  <url>
    <loc>https://aitechhorizon.online/$($hf.Name)</loc>
    <lastmod>2026-09-19</lastmod>
    <priority>0.8</priority>
  </url>
"@ + "`n"
}

$sitemapXml += "</urlset>`n"
Set-Content -Path "$siteDir\sitemap.xml" -Value $sitemapXml -Encoding utf8
Write-Output "Updated sitemap.xml with $($allHtmlFiles.Count) URLs."
