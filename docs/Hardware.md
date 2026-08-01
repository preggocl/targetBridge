# Hardware and Thunderbolt Bridge

## Sender and Receiver roles

TargetBridge Intel Sender is built for `x86_64` Macs running macOS 14 or later.
The Receiver can be Intel or Apple Silicon when the matching Receiver build is
available. Both Macs must support a network path between them; Thunderbolt
Bridge is preferred for predictable latency and isolation from ordinary LAN
traffic.

Verified pair:

- Sender: iMac Retina 5K 27-inch 2020, Intel Core i5, macOS Sequoia 15.7.7.
- Receiver: iMac Retina 4K 21.5-inch, Intel, macOS Monterey.
- Cable path: Thunderbolt Bridge through `bridge0`.

Other combinations are tracked in [Compatibility](Compatibility.md).

## Cables and adapters

Use a cable explicitly certified for Thunderbolt. Thunderbolt 3, 4 and 5 cables
are generally interoperable at the speed of the slowest device and cable.
USB-C describes the connector, not the protocol: charging-only and ordinary
DisplayPort cables do not provide Thunderbolt Bridge.

When connecting a USB-C-style Thunderbolt port to an older Thunderbolt 1 or 2
port, use Apple's bidirectional Thunderbolt 3 to Thunderbolt 2 adapter plus a
Thunderbolt cable. A generic USB-C to Mini DisplayPort adapter will not work for
Thunderbolt networking.

Cable models inherited from upstream reports, without warranty:

- OWC 0.8 m Thunderbolt 5, `OWCCBLTB5C0.8M`.
- OWC 1.0 m Thunderbolt 5, `OWCCBLTB5C1.0M`.

## Network behavior

TargetBridge transports its protocol over TCP. It does not send raw DisplayPort
video over the cable. macOS creates the Thunderbolt Bridge interface, assigns or
accepts its IP configuration, and provides the route.

The Intel Sender:

- enumerates active IPv4 interfaces;
- lets the user choose the source address for each display;
- binds the connection to that address;
- can infer a Receiver address from Bonjour information and the selected
  interface's actual address and netmask;
- never assumes that every installation uses `10.0.0.1/24`;
- does not automatically change IP, mask, router, service order or Wi-Fi state.

The validated addresses happen to be Sender `10.0.0.1/24` and Receiver
`10.0.0.2`, but they are test data rather than hardcoded requirements.

Before troubleshooting TargetBridge, verify the route without changing it:

```bash
route -n get <receiver-ip>
ping -c 3 <receiver-ip>
```

The route should use the intended Thunderbolt Bridge interface. Successful ping
confirms reachability, not sustained video performance.

## One cable or two

One display uses one TCP connection bound to one local interface. Adding a
second Thunderbolt cable does not automatically combine bandwidth or lower
latency. Bonding or striping would require a new multipath protocol at both
ends, and compressed 4K profiles already use far less bandwidth than a single
Thunderbolt link provides.

Extra cables remain useful for separate Receiver displays: each display can use
its own interface, address and stream.

## Other services on the link

Thunderbolt Bridge is a normal macOS network link and can also carry File
Sharing, SSH/SFTP, Internet Sharing, Time Machine or printer traffic. Those are
macOS services, not TargetBridge features. Heavy simultaneous transfers can
still affect latency, so isolate performance tests from unrelated traffic.
