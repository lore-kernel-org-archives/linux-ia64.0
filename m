From: Matt_Domsch@Dell.com
Date: Tue, 24 Jul 2001 12:50:41 +0000
Subject: RE: [Linux-ia64] heads up: ucd-snmp 64-bit problem
Message-Id: <marc-linux-ia64-105590693005895@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I hope someone who's more familiar with SNMP can fix
> this.

One of our server management guys has done a great deal of patching on this
code.  In many many many places in the code, it's assumed that an IP address
is a long, and it's not a simple change.  You've basically got to track down
everywhere an IP address value is used and fix it.  Given this is SNMP,
that's a lot of places.  I'll forward this to him and see what can be done.

Thanks for the info!
-Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

