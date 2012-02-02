From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 02 Feb 2012 17:51:37 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFxx34wqaudKWEV69Vta6k8y4rmiCf9JLjiDZ2gjEic5_Q@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="20cf300e4fbf38891104b7fedaf5"
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb> <20120201194025.GG6148@sunsite.ms.mff.cuni.cz>
 <CA+55aFzVWjqcs1zRF-93_9yHRDS-YgmpgFTzACw6HQ-059U06Q@mail.gmail.com>
 <20120201201631.GW18768@tyan-ft48-01.lab.bos.redhat.com> <CA+55aFwcLpD2Cw5VxZ3ym66QBDAeDam3-hprivrC+keUMXJOtw@mail.gmail.com>
 <874nv9qlau.fsf@houston.quesejoda.com> <Pine.LNX.4.64.1202021726020.25409@wotan.suse.de>
In-Reply-To: <Pine.LNX.4.64.1202021726020.25409@wotan.suse.de>
To: Michael Matz <matz@suse.de>
Cc: Aldy Hernandez <aldyh@redhat.com>, Jakub Jelinek <jakub@redhat.com>, Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

--20cf300e4fbf38891104b7fedaf5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 2, 2012 at 8:28 AM, Michael Matz <matz@suse.de> wrote:
>
> Sure. =A0Simplest example: struct s {int i:24;} __attribute__((packed)).
>
> You must access only three bytes, no matter what. =A0The basetype (int) i=
s
> four bytes.

Ok, so here's a really *stupid* (but also really really simple) patch attac=
hed.

What it does is to simply change the meaning of the SLOW_BYTE_ACCESS thing.

What SLOW_BYTE_ACCESS means is currently is not just that byte
accesses are slow: it means that *everything* but full-word accesses
are slow!

Which is (a) not what the name really implies, (b) not even the
historical meaning of that #define (why? the meaning of "full word"
has changed since: it used to be 32 bits, now it is 64 bits) and (c)
stupid, because that's not how hardware with slow byte accesses really
work anyway.

Finally, it's what causes gcc to do 64-bit accesses to bitfields that
aren't 64 bits in size.

So because of this, I propose gcc just change the rules for what
SLOW_BYTE_ACCESS means.

I propose to just change it to mean "accesses smaller than 32 bits are
slow". That's actually much closer to what the hardware definition
tends to be.

It doesn't fix the generic issue, it doesn't fix any C++11/C11 issues,
it doesn't really change anything, but what it *does* do is make for a
hell of a lot saner model. And it avoids bugs in practice.

NOTE! On at least some machines with SLOW_BYTE_ACCESS, accesses
smaller than a word cannot possibly be atomic anyway (well, not
without jumping through hoops), so the fact that we still extend to 32
bits and the problem of touching too much still exists with 'char' and
'short' variables that are in the same 32-bit word as a bitfield is
kind of unavoidable.

So this suggested patch doesn't really "fix" anything fundamental, but
it is (a) simple, (b) totally untested and (c) at least fixes *some*
cases.

For example, it might fix the 'sig_atomic_t' shadowning, since that is
usually 'int'. It obviously can never fix the issue with volatile
char/short, but at least it works around it for 'long'.

In other words - I'm not trying to say that this patch really "fixes"
anything (except sig_atomic_t interaction, which really does get fixed
for the normal 'int' case). But what it does do is to limit the damage
of a bad situation.

And it is small, and should hopefully be easy to accept even for
stable versions of gcc.

So can we please do something like this for maintenance releases, and
consider the much more complex C++11/C11 issues to be a separate much
bigger issue for the future?

Because the current SLOW_BYTE_ACCESS meaning really is crap. The
*only* thing that architecture define seems to do is literally the
bitfield extract semantics, and it does that horribly horribly badly
as shown by the bug on both 64-bit POWER and Sparc. For no good reason
- both of those have perfectly fine word operations afaik.

I did not look at other architectures that define SLOW_BYTE_ACCESS,
but if they have a 32-bit integer type, I'm pretty sure they support
fast loads/stores of it.

Hacky? Yes. Pretty? No. But better than the disaster that is there
now? Hell yes.

                                   Linus

PS. The only reason I hardcoded "32" was that I didn't know how to ask
the quesion "is this mode at least as wide as 'int'" in the proper gcc
way. So I'm really not suggesting you apply this patch as-is, I'm just
sending it out as a "hey, this is a pretty obvious way to work around
part of the problem, somebody who really knows what they are doing
should probably improve on it".

--20cf300e4fbf38891104b7fedaf5
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gy62yjzi0

IGdjYy9zdG9yLWxheW91dC5jIHwgICAgNSArKysrKwogMSBmaWxlcyBjaGFuZ2VkLCA1IGluc2Vy
dGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZ2NjL3N0b3ItbGF5b3V0LmMg
Yi9nY2Mvc3Rvci1sYXlvdXQuYwppbmRleCBlYTBkNDRkNjRkMjYuLjEzODdjMGU5ZTA2MCAxMDA2
NDQKLS0tIGEvZ2NjL3N0b3ItbGF5b3V0LmMKKysrIGIvZ2NjL3N0b3ItbGF5b3V0LmMKQEAgLTI0
ODYsNyArMjQ4NiwxMiBAQCBnZXRfYmVzdF9tb2RlIChpbnQgYml0c2l6ZSwgaW50IGJpdHBvcywg
dW5zaWduZWQgaW50IGFsaWduLAogCSAgICAgICYmIHVuaXQgPD0gTUlOIChhbGlnbiwgQklHR0VT
VF9BTElHTk1FTlQpCiAJICAgICAgJiYgKGxhcmdlc3RfbW9kZSA9PSBWT0lEbW9kZQogCQkgIHx8
IHVuaXQgPD0gR0VUX01PREVfQklUU0laRSAobGFyZ2VzdF9tb2RlKSkpCisJICB7CiAJICAgIHdp
ZGVfbW9kZSA9IHRtb2RlOworCSAgICAvKiBXaWRlIGVub3VnaD8gKi8KKwkgICAgaWYgKHVuaXQg
Pj0gMzIpCisJICAgICAgYnJlYWs7CisJICB9CiAJfQogCiAgICAgICBpZiAod2lkZV9tb2RlICE9
IFZPSURtb2RlKQo=
--20cf300e4fbf38891104b7fedaf5--
