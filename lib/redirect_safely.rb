# frozen_string_literal: true
require "version"
require "redirect_safely_validator"

module RedirectSafely
  extend self

  def make_safe(uri, default, options = {})
    if uri.present? && safe?(uri, options)
      uri
    else
      default
    end
  end

  def safe?(uri_string, options = {})
    return false if uri_string =~ %r{///}

    uri = URI.parse(uri_string.to_s)

    if uri.path
      return false unless uri.path.start_with?('/')
      return false if uri.path =~ %r{[/\\][/\\]}
    end
    return false unless uri.scheme.nil? || ['http', 'https'].include?(uri.scheme)
    return false unless uri.userinfo.nil?
    return false if options[:path_match] &&
    (uri.path !~ options[:path_match] || File.absolute_path(uri.path) !~ options[:path_match])
    return false if options[:require_absolute] && uri.host.nil?
    return false if options[:require_ssl] && uri.scheme && uri.scheme != 'https'
    return false unless valid_host?(uri.host, options[:whitelist], options[:subdomains])

    true
  rescue URI::InvalidURIError
    false
  end

  private

  def valid_host?(host, whitelist, subdomains)
    raise ArgumentError, "subdomains must start with ." if subdomains && !subdomains.all? { |s| s.start_with?('.') }

    return true if host.nil?
    return true if whitelist&.include?(host)
    return true if subdomains && host.end_with?(*subdomains)

    false
  end
end
