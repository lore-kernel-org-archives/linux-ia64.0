From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 17 Apr 2003 19:52:17 +0000
Subject: Re: [Linux-ia64] floating-point error
Message-Id: <marc-linux-ia64-105590723705540@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705538@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 17, 2003 at 09:21:48PM +0200, Bruno Cornec wrote:
> Sometimes the Oracle process dies with the following error message:
> 
> Apr 17 20:24:48 rx1 kernel: oracle(7148): floating-point assist fault at ip 40000000048b4562
> 
> The ip address is always the same. This happens on all of our 4 nodes
> as it seems randomly. I do not have other debug info as this is the only
> message printed. Some times for the same process the message is printed 
> up to 4 times.
> 
> Kernel used: 2.4.18-e.25 (RedHat update) based on 2.4.18 + a lot of patches
> making it difficult to match with David's releases.
> 
> The error message is a printk warning in traps.c.
> 
> Any idea on what can cause it, and how we could debug more the context ?
> Thanks in advance,

It would be helpful to apply the patch that Martin Hicks sent out
awhile ago which will print the isr as well as the IP.  You can then
decode the isr to figure out exactly what's causing the fault in your
app.

Jesse

