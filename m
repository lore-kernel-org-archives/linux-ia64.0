From: Ulrich Drepper <drepper@redhat.com>
Date: Tue, 10 Apr 2001 17:00:00 +0000
Subject: Re: [Linux-ia64] 32 bit compatibility on IA-64
Message-Id: <marc-linux-ia64-105590693005389@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005385@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005385@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Don Dugger <n0ano@valinux.com> writes:

> I was hoping nobody would run across this.

The IA-32 thread library from glibc 2.2 compiled for i686 and a modern
kernel uses modify_ldt as well.

-- 
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

