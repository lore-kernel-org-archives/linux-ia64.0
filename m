From: "David Wilder" <wilder@us.ibm.com>
Date: Tue, 16 Oct 2001 22:20:20 +0000
Subject: [Linux-ia64] eepro100 hangs
Message-Id: <marc-linux-ia64-105590698805355@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We are seeing lockups of the eepro100 driver on an ia64 box running redhat
7.1 (Revision 1.36 of the eepro100 driver).  I have seen references to
similar problems on this list but have not yet seen a resolution.  The
problem is only seen with the eepro100 driver the e100 driver from intel
works fine.  The system has 4 Gig of RAM.  Here are the details:

Problem description:
    Start a large ftp transfer to the ia64 box (ia64 is the ftp server, the
client issues a put command)
    After several seconds the transfer stalls (the file stops growing).
    At this time we can't ping the ia64 box
   The ia64 box can't ping is router
   We abort the ftp transfer (type ^c on the client)
   It start working again (we can ping in and out)

When the ftp session is terminated the client closes the data connection by
sending a FIN.  Since the ia64 box recovers I have to believe that the box
received the packet with the FIN; therefore, I have a transmit problem.
We ran a  trace of the FTP session on the wire as an attempt to verify that
we had a transmit problem.  What we saw was that the ia64 box stops
acknowledging packets, the client window fills and it stop sending.  Or is
it the other way around?  Unfortunately I don't think this proved I had a
transmit problem.  But I continued on the assumption that I did.

Taking advantage of the fact that ping fails when in the broken state I
instrumented the eepro100 driver to track  ICMP echo requests (outbound).
We reproduced the problem and pinged the router.  The instrumentation
verified that the ICMP packet is:
1) given to driver (seen in speedo_start_xmit() )
2) place on the tx_ring in speedo_start_xmit().
3) removed from the ring in speedo_tx_buffer_gc() after being transmitted.

Any solutions or ideas on how to proceed appreciated.

David  Wilder

I am not a member of this list.



