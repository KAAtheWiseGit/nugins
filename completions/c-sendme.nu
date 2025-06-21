# A cli tool to send directories over the network, with NAT hole punching
export extern sendme [
	--help (-h)	# Print help
	--verison (-V)	# Print version
]

def subcommands [] {
	[help send receive]
}

# Print this message or the help of the given subcommand(s)
export extern "sendme help" [
	subcommand?: string@subcommands
]

def ticket-types [] {
	[
		{value: id, description: "Shortest type which only includes the node ID"}
		{value: addresses, description: "Only includes IP address without a relay url"}
		{value: relay, description: "Adds relay address"}
		{value: RelayAndAddresses, description: "Default, fullest possible address"}
	]
}

def formats [] {
	[hex]
}

def relays [] {
	[
		{value: default, description: "Default relay servers"}
		{value: disabled, description: "Disable relay servers"}
	]
}

export extern "sendme send" [
	--ticket-type: string@ticket-types
	# What type of ticket to use.
	#
	# Use "id" for the shortest type only including the node ID,
	# "addresses" to only add IP addresses without a relay url, "relay" to
	# only add a relay address, and leave the option out to use the biggest
	# type of ticket that includes both relay and address information.
	#
	# Generally, the more information the higher the likelyhood of a
	# successful connection, but also the bigger a ticket to connect.
	#
	# This is most useful for debugging which methods of connection
	# establishment work well.
	#

	--magic-ipv4-addr: string
	# The IPv4 address that magicsocket will listen on.
	#
	# If None, defaults to a random free port, but it can be useful to
	# specify a fixed port, e.g. to configure a firewall rule.
	#

	--magic-ipv6-addr: string
	# The IPv6 address that magicsocket will listen on.
	#
	# If None, defaults to a random free port, but it can be useful to
	# specify a fixed port, e.g. to configure a firewall rule.
	#

	--format: string@formats

	--verbose (-v)

	--relay: string@relays
	# The relay URL to use as a home relay,
	#
	# Can be set to "disabled" to disable relay servers and "default" to
	# configure default servers.
	#

	--clipboard (-c)
	# Store the receive command in the clipboard
	#

	--help (-h)
	# Print help (see a summary with '-h')
	#

	path: path
	# Path to the file or directory to send
]

export extern "sendme receive" [
	--magic-ipv4-addr: string
	# The IPv4 address that magicsocket will listen on.
	#
	# If None, defaults to a random free port, but it can be useful to
	# specify a fixed port, e.g. to configure a firewall rule.
	#

	--magic-ipv6-addr: string
	# The IPv6 address that magicsocket will listen on.
	#
	# If None, defaults to a random free port, but it can be useful to
	# specify a fixed port, e.g. to configure a firewall rule.
	#

	--format: string@formats

	--verbose (-v)

	--relay: string@relays
	# The relay URL to use as a home relay,
	#
	# Can be set to "disabled" to disable relay servers and "default" to
	# configure default servers.
	#

	--help (-h)
	# Print help (see a summary with '-h')
	#
]
