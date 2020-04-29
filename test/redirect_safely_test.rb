# frozen_string_literal: true
require 'test_helper'

class RedirectSafelyTest < ActiveSupport::TestCase
  test "safe? returns false for malformed URIs" do
    refute RedirectSafely.safe?("foo:\\/\??/alskfjalsf")
  end

  test "safe? returns true if the URI is relative" do
    assert RedirectSafely.safe?("/a/b/c")
  end

  test "safe? returns false if the URI is relative but require_absolute is set" do
    refute RedirectSafely.safe?("/a/b/c", require_absolute: true)
  end

  test "safe? returns false if the URI is absolute and no whitelist or subdomains are specified" do
    refute RedirectSafely.safe?("http://test.com/a/b/c")
    refute RedirectSafely.safe?("http://test.com/a/b/c", path_match: /a.b.c/)
    refute RedirectSafely.safe?("http://test.com/a/b/c", require_absolute: true)
    refute RedirectSafely.safe?("https://test.com/a/b/c", require_ssl: true)
  end

  test "require_absolute works with subdomains" do
    refute RedirectSafely.safe?("/a/b/c", require_absolute: true, subdomains: [".test.com"])
    refute RedirectSafely.safe?("http://sub1.other.com/a/b/c", require_absolute: true, subdomains: [".test.com"])
    assert RedirectSafely.safe?("http://sub1.test.com/a/b/c", require_absolute: true, subdomains: [".test.com"])
  end

  test "require_absolute works with whitelist" do
    refute RedirectSafely.safe?("/a/b/c", require_absolute: true, whitelist: ["test.com"])
    refute RedirectSafely.safe?("http://other.com/a/b/c", require_absolute: true, whitelist: ["test.com"])
    assert RedirectSafely.safe?("http://test.com/a/b/c", require_absolute: true, whitelist: ["test.com"])
  end

  test "require_absolute works with require_ssl" do
    refute RedirectSafely.safe?("/a/b/c", require_absolute: true, require_ssl: true, whitelist: ["test.com"])
    refute RedirectSafely.safe?(
      "http://test.com/a/b/c", require_absolute: true, require_ssl: true, whitelist: ["test.com"]
    )
    assert RedirectSafely.safe?(
      "https://test.com/a/b/c", require_absolute: true, require_ssl: true, whitelist: ["test.com"]
    )
  end

  test "require_ssl disallows http:// absolute urls" do
    refute RedirectSafely.safe?("http://test.com/a/b/c", require_ssl: true, whitelist: ["test.com"])
    assert RedirectSafely.safe?("https://test.com/a/b/c", require_ssl: true, whitelist: ["test.com"])
  end

  test "require_ssl without require_absolute allows paths" do
    assert RedirectSafely.safe?("/a/b/c", require_ssl: true, whitelist: ["test.com"])
  end

  test "whitelist and subdomains can be used together" do
    assert RedirectSafely.safe?(
      "http://abc.com/a/b/c", whitelist: ["abc.com", "def.com"], subdomains: [".ghi.com", ".jkl.com"]
    )
    assert RedirectSafely.safe?(
      "http://def.com/a/b/c", whitelist: ["abc.com", "def.com"], subdomains: [".ghi.com", ".jkl.com"]
    )
    assert RedirectSafely.safe?(
      "http://sub1.ghi.com/a/b/c", whitelist: ["abc.com", "def.com"], subdomains: [".ghi.com", ".jkl.com"]
    )
    assert RedirectSafely.safe?(
      "http://sub1.jkl.com/a/b/c", whitelist: ["abc.com", "def.com"], subdomains: [".ghi.com", ".jkl.com"]
    )
    refute RedirectSafely.safe?(
      "http://abc.com.invalid/a/b/c", whitelist: ["abc.com", "def.com"], subdomains: [".ghi.com", ".jkl.com"]
    )
    refute RedirectSafely.safe?(
      "http://jkl.com.invalid/a/b/c", whitelist: ["abc.com", "def.com"], subdomains: [".ghi.com", ".jkl.com"]
    )
  end

  test "safe? returns false if the path is not matched" do
    refute RedirectSafely.safe?("/a/b/c", path_match: /no_match/)
  end

  test "safe? returns true if the path is matched" do
    assert RedirectSafely.safe?("/a/b/c", path_match: /a.b.c/)
  end

  test "path_match checks path and normalized path" do
    assert RedirectSafely.safe?("/admin/valid", path_match: %r{\A/admin/})
    refute RedirectSafely.safe?("/admin/../invalid", path_match: %r{\A/admin/})
    refute RedirectSafely.safe?("/invalid/../admin/valid", path_match: %r{\A/admin/})
  end

  test "safe? returns false if the domain is not in the whitelist" do
    refute RedirectSafely.safe?("http://test.com/a/b/c", whitelist: ["someOtherSite.com"])
    refute RedirectSafely.safe?("http://sub1.test.com/a/b/c", whitelist: ["test.com"])
    refute RedirectSafely.safe?("http://badtest.com/a/b/c", whitelist: ["test.com"])
  end

  test "safe? returns true if the domain is in the whitelist" do
    assert RedirectSafely.safe?("http://test.com/a/b/c", whitelist: ["test.com"])
  end

  test "safe? returns true if the url is relative and a whitelist is specified" do
    assert RedirectSafely.safe?("/a/b/c", whitelist: ["test.com"])
  end

  test "safe? returns false if the domain is not a valid subdomain" do
    refute RedirectSafely.safe?("http://sub1.test.com/a/b/c", subdomains: [".someOtherSite.com"])
    refute RedirectSafely.safe?("http://badtest.com/a/b/c", subdomains: [".test.com"])
    refute RedirectSafely.safe?("http://evil.com\\.test.com/a/b/c", subdomains: [".test.com"])
  end

  test "safe? returns true if the domain is a valid subdomain" do
    assert RedirectSafely.safe?("http://sub1.test.com/a/b/c", subdomains: [".test.com"])
  end

  test "safe? returns true if the url is relative and a subdomain is specified" do
    assert RedirectSafely.safe?("/a/b/c", subdomains: [".test.com"])
  end

  test "safe? raises if a subdomain doesn't begin with ." do
    assert_raise ArgumentError do
      RedirectSafely.safe?("http://badtest.com/a/b/c", subdomains: [".test.com", "test.com"])
    end
  end

  test "safe? returns false if the domain is http but require_ssl is set" do
    refute RedirectSafely.safe?("http://test.com/a/b/c", whitelist: ["test.com"], require_ssl: true)
  end

  test "safe? returns true if the domain is https and require_ssl is set" do
    assert RedirectSafely.safe?("https://test.com/a/b/c", whitelist: ["test.com"], require_ssl: true)
  end

  test "safe? returns false if the scheme is not http or https" do
    refute RedirectSafely.safe?("javascript:alert(1)")
    refute RedirectSafely.safe?("data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K")
    refute RedirectSafely.safe?("blah://test.com/abc")
  end

  test "safe? returns false if double slashes or backslashes are present in path" do
    refute RedirectSafely.safe?("////google.com")
    refute RedirectSafely.safe?("////@google.com")
    refute RedirectSafely.safe?("\\\\google.com")
    refute RedirectSafely.safe?("/abc//def")
    refute RedirectSafely.safe?("/abc\\\\def")
  end

  test "safe? returns false when the host is empty" do
    refute RedirectSafely.safe?("///google.com")
    refute RedirectSafely.safe?("http:///google.com")
    refute RedirectSafely.safe?("https:///google.com")
  end

  test "safe? returns false for an invalid URI" do
    refute RedirectSafely.safe?("http://goo<gle.com")
  end

  test "safe? requires the path to begin with a slash" do
    refute RedirectSafely.safe?("a/b/c")
    refute RedirectSafely.safe?(".mx")
  end

  test "safe? requires the userinfo to be empty" do
    assert RedirectSafely.safe?("https://abc.test.com/x", subdomains: [".test.com"])
    refute RedirectSafely.safe?("https://example.com\\@abc.test.com/x", subdomains: [".test.com"])
    refute RedirectSafely.safe?("https://foobar@abc.test.com/x", subdomains: [".test.com"])
    refute RedirectSafely.safe?("https://foo:bar@abc.test.com/x", subdomains: [".test.com"])

    assert RedirectSafely.safe?("https://abc.test.com/x", whitelist: ["abc.test.com"])
    refute RedirectSafely.safe?("https://example.com\\@abc.test.com/x", whitelist: ["abc.test.com"])
  end

  test "make_safe returns the backup if the URI isn't present" do
    assert_equal "foo", RedirectSafely.make_safe("", "foo")
  end

  test "make_safe returns the backup if the URI isn't safe" do
    assert_equal "foo", RedirectSafely.make_safe("foo:\\/\??/aslkjals", "foo")
    assert_equal "foo", RedirectSafely.make_safe("/a/b/c", "foo", require_absolute: true)
  end

  test "make_safe returns the URI if it is safe" do
    assert_equal "/a/b/c", RedirectSafely.make_safe("/a/b/c", "foo")
    assert_equal "http://test.com/a/b/c",
      RedirectSafely.make_safe("http://test.com/a/b/c", "foo", whitelist: ["test.com"])
  end

  test "make_safe raises if a subdomain doesn't begin with ." do
    assert_raise ArgumentError do
      RedirectSafely.make_safe("http://badtest.com/a/b/c", "foo", subdomains: [".test.com", "test.com"])
    end
  end
end
