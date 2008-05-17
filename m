From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 17 May 2008 00:06:21 +0000
Subject: RE: [PATCH 00/15] ia64/pv_ops take 5
Message-Id: <1FE6DD409037234FAB833C420AA843EC015B26C6@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12095585682308-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12095585682308-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I started looking at this patch set.

Parts 1-9 applied ok, but part10 (entry.S) failed to apply because of
recent changes to this file to fix the problems with warnings when
trying to get locks with interrupts blocked.

I thought this would be a good point to test the bisectability
of this patch set and started a build with just parts 1-9 applied.
The build was perfectly clean, but the kernel hung during boot
(possibly when first trying to run user processes by the look
of the last few messages on the console.

The code with parts 1-9 applied still looks readable, but I
think we may need some documentation later to help with maintainability.
Perhaps even a tool that can check to make sure people don't add
direct uses of instructions to .S files that need to be
paravirtualized.

I'm talking to some of the virtualization people here to
see if they can help me set up a system so that I will be
able to test out the non-native execution paths.

-Tony
