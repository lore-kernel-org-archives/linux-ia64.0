From: Jes Sorensen <Jes.Sorensen@cern.ch>
Date: Tue, 25 Apr 2000 07:37:01 +0000
Subject: Re: [Linux-ia64] Bug report: two 'kills' kill the shell
Message-Id: <marc-linux-ia64-105590678205033@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205029@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205029@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Robboy <robboy@co.intel.com> writes:

David> I started up 4 of them in background from one shell.  Then went
David> to another window and started killing them with the 'kill'
David> command (not kill 9, just plain kill).  The second 'kill' kills
David> the shell, consistently.  It looks like maybe the shell can
David> handle one SIGCHILD but not two of them.

There are some problems with the signal handling in the current
kernels, I suspect thats what you're seeing.

Jes


