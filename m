From: Stephane Eranian <eranian@cello.hpl.hp.com>
Date: Wed, 26 Apr 2000 16:19:43 +0000
Subject: Re: [Linux-ia64] Lost clock tick on CPU 0 (now=3b6bca57923, next=3b6b627b32c)!!t
Message-Id: <marc-linux-ia64-105590678205051@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205046@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205046@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hi,
> 
> I am getting regular messages like the one above on my Lion system. I
> appears to me that these messages are in relation to other errors I am
> getting like hanging processes NFS IO errors etc.
> 
> Can any one comment on this?
> 

On your Lion are you using the builtin eepro 100 controller ? We have 
seen things like that with that flaky controller. Ever since we added
an extra eepro100 PCI card in the machine I don't recall ever seeing this
again.


-Stephane


