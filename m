From: "Reed, Robert W" <robert.w.reed@intel.com>
Date: Tue, 19 Sep 2000 19:22:27 +0000
Subject: FW: [linux-ia64] Predication vs. Branching
Message-Id: <marc-linux-ia64-105590678205507@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205504@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205504@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jonathan writes:
    Now the question is, at what point does it become more efficient to
branch
    rather than predicate? I assume this would dependent on the pipeline
depth
    and total Instruction Fetch Bandwidth.

It has less to do with those factors than it does with statistical
factors regarding the code graph you're trying to execute.
Imagine, for example, an if-then-else clause.  If the then and else
branches can be packed into the same number of execution cycles,
predication is a clear win.  But if the branches are unbalanced,
say one takes 10 cycles and the other can be done in 2, then the
answer depends on execution frequency.  Predicated, either branch
is going to take 10 cycles.  If the longer side gets executed 80% of
the time then predication makes sense--the penalty paid 20% of the
time should be less than the pipeline stalls imposed by the jumps.
(A more accurate answer about the exact balance point would be
dependent on the pipeline depth and other factors as you suggest.)
If the short side gets the 80%, then branching should in general
win over predication.
_______________________________________________________________________
Robert Reed                                     Robert.W.Reed@intel.com
Intel ISV Performance Lab/ Oregon Application Analysis Team
Dept. EY2-05, 5350 NE Elam Young Parkway             phone 503-696-3814
Hillsboro, OR 97124-6461                               fax 503-696-3730
_______________________________________________________________________
-----Original Message-----
From: Jonathan Case Nicklin [mailto:nicklin@missioncriticallinux.com]
Sent: Tuesday, September 19, 2000 6:14 AM
To: linux-ia64@ia64linux.org
Subject: Re: [linux-ia64] Predication vs. Branching


Dan Pop wrote:

> On Tue, 19 Sep 2000, Jonathan Case Nicklin wrote:
>
> > Dan Pop wrote:
> >
> > > On Tue, 19 Sep 2000, Jonathan Case Nicklin wrote:
> > >
> > > > This might not be the appropriate forum, but what the heck. Does
anyone
> > > > have
> > > > a definitive answer on what happens to predicated instructions
that are
> > > > not
> > > > executed (ie where in the pipeline are they discarded).
> > >
> > > According to the manual, they become NOPs of the appropriate type.

> > >
> > > Dan
> >
> > Dan,
> >     But When? Do they always consume execution resources or are they

> > dropped as soon as their predicate dependency is fulfilled...
assuming their
> >
> > dependent predicate evaluates false and that there are predicate
dependent
> > instructions in the pipeline.
>
> According to the Itanium microarchitecture manual, they do consume
> execution resources, by their mere presence in the bundle.
>
> I.e. the following code still keeps the CPU busy for one cycle:
>
> {.mib
>         nop.m   0
>         nop.i   0
>         nop.b   0
> }
> {.mib
>         nop.m   0
>         nop.i   0
>         nop.b   0
> }
>
> No execution unit can be assigned to a more useful instruction during
> that cycle.
>
> Replacing the NOPs by predicated away instructions of the
> corresponding types shouldn't change anything.
>
> Dan
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

Dan,

okey-dokey... The predicated instructions that are not executed do
consume
execution resources because they evaluate to NOPs... and NOPs do carry
all
the way through the pipeline until commit (this is what i was curious
about).
Now the question is, at what point does it become more efficient to
branch
rather than predicate? I assume this would dependent on the pipeline
depth
and total Instruction Fetch Bandwidth.

Thanks,
Jonathan Nicklin


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


