namespace :icons do
  desc "Sync Flowbite Icons from GitHub into app/assets/images/icons"
  task :sync do
    require "open-uri"
    require "json"

    repo = "themesberg/flowbite-icons"

    license_dest = Rails.root.join("app/assets/images/icons", "LICENSE")
    FileUtils.mkdir_p(license_dest.dirname)
    File.write(license_dest, URI.open("https://raw.githubusercontent.com/#{repo}/main/LICENSE").read)
    puts "✓ LICENSE"

    %w[outline solid].each do |variant|
      api = "https://api.github.com/repos/#{repo}/contents/src/#{variant}"
      tree = JSON.parse(URI.open(api).read)

      tree.each do |entry|
        next unless entry["type"] == "dir"
        category = entry["name"]
        files = JSON.parse(URI.open(entry["url"]).read)
        files.each do |f|
          next unless f["name"].end_with?(".svg")
          dest = Rails.root.join("app/assets/images/icons", variant, "#{f['name']}")
          FileUtils.mkdir_p(dest.dirname)
          File.write(dest, URI.open(f["download_url"]).read)
          puts "✓ #{variant}/#{f['name']}"
        end
      end
    end
  end
end
