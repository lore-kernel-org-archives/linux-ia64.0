From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Mon, 20 Sep 2004 20:44:32 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[1/6]-ACPI core enhancement support
Message-Id: <20040920134432.A16611@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <200409201326.44946.dtor_core@ameritech.net> <20040920120128.A15677@unix-os.sc.intel.com> <200409201426.31672.bjorn.helgaas@hp.com>
In-Reply-To: <200409201426.31672.bjorn.helgaas@hp.com>; from bjorn.helgaas@hp.com on Mon, Sep 20, 2004 at 02:26:31PM -0600
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, Dmitry Torokhov <dtor_core@ameritech.net>, acpi-devel@lists.sourceforge.net, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, Sep 20, 2004 at 02:26:31PM -0600, Bjorn Helgaas wrote:
> On Monday 20 September 2004 1:01 pm, Keshavamurthy Anil S wrote:
> > On Mon, Sep 20, 2004 at 01:26:44PM -0500, Dmitry Torokhov wrote:
> > > Also, introducing recursion (depth does not seem to be limited here) is
> > > not a good idea IMHO - better convert it into iteration to avoid stack
> > > problems down teh road.
> > Humm, I guess recursion should be fine and even though the code does not have
> > an explicit limit, the ACPI namespace describing the Ejectable device will limit the
> > number of recursible devices. And I believe this won;t be more than 3 to 4 level depth.
> > Hence recursion is fine here.
> > 
> > If you still strongly believe that recursion is not the right choice here, 
> > let me know and I will convert it to iteration.
> 
> I'm also in favor of removing the recursion, if only because it
> allows local analysis.  I.e., a correctness argument based solely
> on the code in the patch is much more useful than one that relies
> on properties of an external and mostly unknown ACPI namespace.

Okay, I am convinced, I will post an updated patch to address this soon.
Again thanks for the feedback and more comments are welcome:)

-Anil

