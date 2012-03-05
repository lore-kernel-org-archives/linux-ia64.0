From: Jonathan Nieder <jrnieder@gmail.com>
Date: Mon, 05 Mar 2012 23:42:40 +0000
Subject: Re: [regression] Re: [PATCH 2/3] futex: Sanitize cmpxchg_futex_value_locked API
Message-Id: <20120305234240.GB1360@burratino>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110307021127.GB31188@google.com>
 <alpine.LFD.2.00.1103082114270.2787@localhost6.localdomain6>
 <20110309112550.GA3050@google.com>
 <alpine.LFD.2.00.1103101948540.2787@localhost6.localdomain6>
 <20110311021654.GA26122@google.com>
 <20110311024851.GC26122@google.com>
 <20120305000112.GA27512@burratino>
 <3908561D78D1C84285E8C5FCA982C28F041A65@ORSMSX104.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F041A65@ORSMSX104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Michel Lespinasse <walken@google.com>, =?utf-8?Q?=C3=89meric?= Maschino <emeric.maschino@gmail.com>, Patrick Baggett <baggett.patrick@gmail.com>, Jakub Jelinek <jakub@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Luck, Tony wrote:

>> It doesn't look like the return value (r8) is actually being set beyond
>> initialized to 0. If there is some ia64 instruction that modifies it, GCC
>> doesn't know about it from the inline assembly (r8 doesn't appear in the
>> inputs/outputs list). From looking at the x86 version (agh, inline asm is
>> hard to parse), it does modify the return value based on whether the
>> comparison was a success or not, and the return value is certainly used =
by
>> the callers.
>
> The commit comment for the change makes it sound like the return value
> is an error code (-ENOSYS if the function isn't implemented/configured;
> -EFAULT if the user address is bogus) - or zero if nothing bad happened.

Yes, that's right.

> Not "the comparison was a success or not".
>
> What's the real answer? The ia64 code is returning 0 regardless of whethe=
r the
> compare/exchange found the old value or not.  Is this a bad assumption?

No, I think something else is wrong, though I don't know what it would
be.

=C3=89meric, was the bisection result reproducible?  E.g., if you try
building 37a9d912b24f and 37a9d912b24f^ again, does the former
consistently produce and the latter consistently not produce a crashy
system?
