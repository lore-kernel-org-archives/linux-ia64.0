From: Dan Pop <Dan.Pop@cern.ch>
Date: Tue, 13 Nov 2001 00:00:01 +0000
Subject: Re: [Linux-ia64] Unaligned access in ia64
Message-Id: <marc-linux-ia64-105590698805480@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805472@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805472@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Mon, 12 Nov 2001, Pereira, D LailaX E wrote:

> I have an application running fine on the Intelx86 machines. When I run the
> same on itanium machine ( linux OS) , I get the following  errors:
> stress.udp(16868):unaligned access  to 0x4000000000003541,
> ip=0x400000000001cfe0
> stress.udp(16868):unaligned access  to 0x4000000000003541,
> ip=0x400000000001c551
> 
> What could be the possible causes for this?

You're probably converting pointer to char to pointers to types with
more restrictive alignment requirements.

> Can anyone please point out?
> what are the general cautions to be taken while porting applications to
> itanium? for eg any pointer conversions , int conversions etc 

Each C type wider than char has its own alignment requirements.  Its
address must be a multiple of its size.  The diagnostics you have
quoted above suggest that your program attempts to place such objects
at incorrectly aligned addresses (usually by converting char pointers
or void pointers to pointers to other types).

Dan


