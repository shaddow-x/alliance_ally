#!/usr/bin/env -S falcon host

load :rack

hostname = File.basename(__dir__)
port = ENV["PORT"] || 9292

rack hostname do
  # cache true
  endpoint Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}").with(protocol: Async::HTTP::Protocol::HTTP11)
end
