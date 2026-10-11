# Prefixes root-relative links with site.baseurl.
#
# Articles link to each other as "/ingest/mapping", which is right when the
# site is served from the root of a domain (documentation.cluedin.net) but not
# when it is served from a subpath, as a GitHub Pages project site is
# (<user>.github.io/<repo>/). When baseurl is empty this does nothing.
module BaseurlLinks
  ATTR = /(\s(?:href|src|action)=["'])\/(?!\/)/

  def self.rewrite(doc)
    baseurl = doc.site.config["baseurl"].to_s.chomp("/")
    return if baseurl.empty? || doc.output.nil?
    return unless doc.output_ext == ".html"

    prefix = baseurl.delete_prefix("/") + "/"
    doc.output = doc.output.gsub(ATTR) do
      rest = Regexp.last_match.post_match
      rest.start_with?(prefix) ? Regexp.last_match(0) : "#{Regexp.last_match(1)}#{baseurl}/"
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  BaseurlLinks.rewrite(doc)
end
