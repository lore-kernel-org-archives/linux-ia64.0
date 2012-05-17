From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Thu, 17 May 2012 10:29:04 +0000
Subject: Re: [PATCH 3.0.y, 3.2.y] ia64: Add accept4() syscall
Message-Id: <CAA9xbM4kDr6ekBULBRTM9jjCqn6zU_sfgrWtjGwY=w_miDyG8A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120516215700.GA10476@burratino>
In-Reply-To: <20120516215700.GA10476@burratino>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

2012/5/17 Ben Hutchings <ben@decadent.org.uk>:
> On Wed, 2012-05-16 at 16:57 -0500, Jonathan Nieder wrote:
>> From: =C9meric Maschino <emeric.maschino@gmail.com>
>>
>> [...]
>>
>> This patch simply adds accept4() to ia64.
> [...]
>
> Queued up for 3.2.y.

Hasn't it been already added [1]?

Indeed, I'm no more having this issue with (at least) Debian kernel
3.2.14-1 and 3.2.16-1.

Discussion about direct syscalls and indirect socketcalls [2], with
PPC deprecating socketcalls, is beyond my knowledge. Jonathan, was it
your point?

     Emeric


[1] http://bugs.debian.org/cgi-bin/bugreport.cgi?bugd7825#123
[2] http://thread.gmane.org/gmane.linux.kernel.cross-arch/11888/focus=11907
