From: David Lombard <david.lombard@mscsoftware.com>
Date: Wed, 26 Apr 2000 17:36:56 +0000
Subject: Re: [Linux-ia64] Lost clock tick on CPU 0 (now=3b6bca57923,
Message-Id: <marc-linux-ia64-105590678205052@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205046@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205046@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
>> [Linux-ia64] Lost clock tick on CPU 0 (now;6bca57923, next;6b627b32c)!!t
> 
> On your Lion are you using the builtin eepro 100 controller ? We have
> seen things like that with that flaky controller. Ever since we added
> an extra eepro100 PCI card in the machine I don't recall ever seeing this
> again.
> 

Thanks for the info!  We've been getting that on our systems too.  We
haven't seen any other network-related issues, but we haven't pushed
that too much. 

-- 
David N. Lombard
MSC.Software


