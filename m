From: Ulrich Drepper <drepper@redhat.com>
Date: Tue, 11 Sep 2001 04:30:02 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805169@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

> As far as I can see, neither LSB nor FHS address the issue of where
> to place emulation files, so I'll propose a prefix of
> "/emul/ia32-linux/" as a starter.  Any objections?

Not that I care, but this is clearly a place for a new /proc entry
which can be changed by the sysadmin.

-- 
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

