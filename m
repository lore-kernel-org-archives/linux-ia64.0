From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 21 Mar 2001 20:17:30 +0000
Subject: [Linux-ia64] Re: sprofil() implementation
Message-Id: <marc-linux-ia64-105590693005326@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

> Attached below is an implementation of the sprofil() call.

Thanks, I've added the patch.  There was one bug left (on 32-bit
archs) and I did some reformatting but essentially it is plainly
accepted.  Thanks.


But one word of warning: this interface is insufficient.  We need a
way to dynamically add and remove new segments.  This is necessary to
support dlopen() etc.

-- 
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

