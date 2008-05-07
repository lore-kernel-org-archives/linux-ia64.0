From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 May 2008 21:50:32 +0000
Subject: RE: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1FE6DD409037234FAB833C420AA843EC0147C8B9@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> It sure sounds wrong to me that notify_resume_user runs with interrupts
> disabled.

The "leave kernel" paths on ia64 are a bit tortuous ... clearly there
is some point at which the kernel needs to lock out interrupts and
just get on with returning to the user.  We don't want to allow races
after we check the TIF* bits where interrupts could result in more
signals pending for the process.

Perhaps we can re-order things to satisfy all the interrupts enabled
vs. interrupts disabled requirements.

-Tony

