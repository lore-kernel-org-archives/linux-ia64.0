From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 18:27:13 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434256308215@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Sep 2003 10:57:12 -0700, "David S. Miller" <davem@redhat.com> said:

  DaveM> On Tue, 23 Sep 2003 12:58:59 -0500
  DaveM> "Van Maren, Kevin" <kevin.vanmaren@unisys.com> wrote:

  >> Rate-limited unaligned loads in user space make a lot more sense, since
  >> they _may_ point out issues in the code.

  DaveM> That's what generates the bulk of the noise in people's ia64
  DaveM> dmesg output.

At the moment, there are two ways to control the unaligned message printing:

 - use the dmesg command to lower the printing threshold below KERN_WARNING
   ("dmesg -n4", IIRC)

 - use prctl --unalign=silent to turn off unaligned printing for a
   particular task and its children

If these mechanisms are not sufficient, there is nothing to stop
anyone from cooking up a patch.  For my puposes, what's there works
nicely so I myself have no plans to make changes in this area.

	--david
