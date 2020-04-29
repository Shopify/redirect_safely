# RedirectSafely

Sanitize `return_to`-style URLs, including some edge cases that you probably missed.

`RedirectSafely` is used in production and extracted from Shopify.

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'redirect_safely', '~> 1.0'
```

And then execute:

    $ bundle

## Usage

- `RedirectSafely.safe?(url, options)`

  Return true if the URL is considered "safe", false otherwise.

  ### Parameters:
    - `url` String (required) - The URL to test

  ### Options:
    - `path_match` Regexp (optional) - Match the path portion of the URL against a regexp
    - `require_absolute` Boolean (optional) - If true, require an absolute URL (domain must be included in `whitelist`)
    - `require_ssl` Boolean (optional) - If true, and an absolute URL is provided, require a URL starting with `https://`
    - `whitelist` String[] (optional) - Whitelisted domains for checking absolute URLs
    - `subdomains` String[] (optional) - Whitelisted subdomains for checking absolute URLs. Must start with a leading `.`.

- `RedirectSafely.make_safe(url, default, options)`

  Return `url` if it's safe, otherwise return `default`.

  Shares options with `safe?`, and is roughly equivalent to:

  ```ruby
  safe_url = RedirectSafely.safe?(url) ? url : default
  ```

- `RedirectSafelyValidator`

  If you persist a redirect URL on a model, you can validate that it is `safe?`:

  ```ruby
  class Request
    validates :return_to, redirect_safely: true
  end
  ```

  You can pass any options supported by `safe?` (but *not* those added by `make_safe`). In the event that you need more
  control over the options (ie, dynamically producting a whitelist based on other model attributes), write a custom
  `validate` method:

  ```ruby
  class Request
    validates :store_url, presence: true
    validate :return_to, presence: true

    validate :return_to_is_safe

    private

    def return_to_is_safe
      errors.add(:return_to, :invalid) unless RedirectSafely.safe?(return_to, whitelist: URI.parse(store_uri).host)
    end
  end
  ```
