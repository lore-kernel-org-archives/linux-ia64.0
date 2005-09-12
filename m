From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Mon, 12 Sep 2005 16:27:25 +0000
Subject: RE: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD802C06819@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>From: Luck, Tony
>Sent: 2005=C4=EA9=D4=C210=C8=D5 6:36
>
>>I am aware of at least two ia64 virtualization systems
>>that rely on the existing behavior to compensate for
>>the fact that one guest linux may be inactive while another
>>is active.  This isn't to say that another solution
>>couldn't be found, but just turning off the existing
>>behavior doesn't seem like a good alternative.
>
>There must be some minimum frequency at which a hypervisor
>allows a guest to run in order for it to operate normally
>[e.g. a guest that gets no cpu time for several seconds at
>a stretch will experience network time-outs with external
>systems that it is unable to supply with "keep-alive" packets].
>
>I'm not sure what that minimum frequency is, but I expect that
>it may be contrained by some of the shorter TCP timeouts.  I
>think that there is one around the 200 milli-second mark.

Yes, this is one important facet in virtualization system. In one of our ti=
me virtualization approaches, we add max_jump for max suspension period whe=
n one guest is scheduled off. Once the guest is back alive, check is made u=
pon max_jump whether exceeds. If exceeds, it means that we can't show a vir=
tual itc to guest with actual drift which may make device request timeout. =
Instead we record the actual drift in another field, and only show guest wi=
th a max_jump increment on virtual itc. Next time the cached drift value wi=
ll be checked again, and compensate virtual itc gradually. Max_jump is set =
as 500ms by default, which is tunable as Tony's example here.

Thanks,
Kevin
