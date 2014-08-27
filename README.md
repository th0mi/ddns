DynDNS replacement via AWS route 53
====

This little script was born out of a desire to get rid of DynDNS and similar services. There are several scripts around that do the job, but most of them are pretty complicated because they try to do the Amazon AWS calls manually.

This script requires a fully configured installation [AWS cli](http://aws.amazon.com/cli/) which is used to do the update.

What it does:
1. Use curl to get the local IP address from a router status page
2. Check whether the internally reported IP matches the one known to a public DNS server
3. If it doesn't match, create an update record to update a hosted zone file on AWS Route 53

This can be run from a cron job every couple of minutes to ensure the ip is always current. 