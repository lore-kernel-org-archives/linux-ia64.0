From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 11 Nov 2002 21:21:34 +0000
Subject: [Linux-ia64] RE: +AFs-Linux-ia64+AF0- reader-writer livelock proble
Message-Id: <marc-linux-ia64-105590709805392@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805391@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805391@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 11 Nov 2002 14:36:38 -0600, "Van Maren, Kevin" <kevin.vanmaren@unisys.com> said:

  Van> I have not looked at this, but I don't believe it is the right
  Van> way to solve the problem: users who +AF8-need+AF8- to use all
  Van> the CPUs for computation would be punished just to work around
  Van> a kernel implementation issue: that's like saying don't allow
  Van> processes to allocate virtual memory because if the VM is
  Van> over-committed by X amount the kernel deadlocks.

  Van> It would be a bad hack to limit the system-call rate just to
  Van> prevent livelock.

Certainly.  I didn't suggest PRM as a way to _solve_ the livelock
problem, but since Mario asked for a method to cap CPU utilization, I
mentiond it.

	--david

