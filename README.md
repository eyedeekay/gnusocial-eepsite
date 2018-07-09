Configuring a GNU Social instance as a Hidden Service on Tor and i2p
====================================================================

*WARNING: This is not ready yet.*

This tutorial is a step-by-step walkthrough of how I set up a GNU Social
as an eepSite, a Tor Hidden Service, and allow it to communicate with i2p, Tor,
and Clearnet GNU Social instances.

Background/Goals
----------------

For the purposes of this tutorial, we're trying to set up an otherwise normal,
federated GNU Social node that participates fully in the network, but making
itself available as an eepSite and a hidden service by default. In this guide,
the service you host **will not be anonymous**, it's purpose is to provide
anonymity to users. In order to be hidden-only but also be a secure participant
in the Fediverse, it would be necessary to get a certificate for an onion-only
domain which isn't possible yet [1].

Preparation
-----------

Far and away the easiest part of this to figure out is the actual hidden service
configuration.

### Docker

### i2p

### Tor

### privoxy

### Dynamic DNS

### Let's Encrypt

Patching the GNU Social Defaults
--------------------------------

Here's where we make sure that the proxy configuration is pre-set by default to
make sure that they are used even when configuring the instance.


Setting up MariaDB
------------------

Initial GNU Social Configuration
--------------------------------


Footnote:
---------

[1] Originally, I had intended for this to be hidden-only. In order to do this,
it's possible to set GNU Social configuration settings proxy\_host, proxy\_port
to direct traffic to an HTTP proxy server, but since i2p's http proxy can only
be used to access other eepsites, we'll have to use Privoxy to route requests
for i2p resources to i2p, and clearnet resources to Tor. But since I also want
to run MariaDB in a separate container, Privoxy will need an exception for the
MariaDB container. Since we're running a service, we're only really concerned
with obfuscating our physical location, not making ourselves unidentifiable to
other GNU Social nodes. Unfortunately, for now, it's impossible to get an EV
certificate for a .onion-only domain from Let's Encrypt, so it's not possible
to identify yourself to the other GNU Social instances in that way, or
communicate in an encrypted way with the rest of the Fediverse. That's limiting
to us, as we will only be able to communicate with nodes that allow HTTP
connections, which is bad on the clearnet. It's not ideal on darknets either,
but it's less bad.
