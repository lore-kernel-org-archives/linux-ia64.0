From: Alex Williamson <awilliam@fc.hp.com>
Date: Tue, 04 Sep 2001 14:09:45 +0000
Subject: Re: [Linux-ia64] Proc num on an MP plateform
Message-Id: <marc-linux-ia64-105590698805117@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805116@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805116@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gerard,

   ia64_get_lid() returns the processor interrupt id and eid.  That
should be enough to uniquely identify which CPU you're one.

	Alex

gerard wrote:
> 
> Hi
> I am working on a MP system and I need to know on which
> proc num I am running, is there a macro/function call to do this?(kernel
> mode).
> 
> Thanks in advance.
> Gerard LYONNAZ
> 

--
Alex Williamson                                  Linux Development Lab
awilliam@fc.hp.com                                     Hewlett Packard
970-898-9173                                          Fort Collins, CO

