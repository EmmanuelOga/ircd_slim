After do
  clients.values.each { |client| client.stop }
  clients.clear
end
