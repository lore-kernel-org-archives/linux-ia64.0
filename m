From: "Scott M. Dier" <sdier@cs.umn.edu>
Date: Tue, 21 Nov 2000 20:58:38 +0000
Subject: [Linux-ia64] nue problems
Message-Id: <marc-linux-ia64-105590678205760@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello!

I am attempting to install ski and nue for a group of researchers here,
and I am having problems.

When nue-glibc21 is executed, it attemps to do this:

getcwd("/", 4095)                       = 2
chdir("/nue")                           = 0
chdir("")                               = -1 ENOENT (No such file or
directory)


The problem being it cant chdir into "".  The version is 1.0 of nue.

I can't seem to figure out whats going on.  Direct email would be
appreciated because I havent subscribed to the list.  Thanks

-- 
Scott Dier <sdier@cs.umn.edu> 
Computer Science/ITLabs Systems Staff
University of Minnesota, Twin Cities


