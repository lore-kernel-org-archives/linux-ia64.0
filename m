From: Ulrich Drepper <drepper@redhat.com>
Date: Fri, 16 Mar 2001 21:15:40 +0000
Subject: Re: [Linux-ia64] setcontext/getcontext support
Message-Id: <marc-linux-ia64-105590693005289@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005277@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005277@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've added the patch now, with some changes:

- we are not going to add a new subdir ia64/.  The sys/ subdir is there
  for just that purpose

- there seems to be no reason to export __start_context.  It was exported
  with the wrong version anyway

- I've made the test program more robust.  Especially not having it fail
  if the functions are not implemented was necessary.

Thanks,

-- 
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

