From: Bill Nottingham <notting@redhat.com>
Date: Tue, 05 Jun 2001 18:24:11 +0000
Subject: [Linux-ia64] [PATCH] fix elilo invocations from the boot manager
MIME-Version: 1
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Message-Id: <marc-linux-ia64-105590693005695@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

In some odd cases, when the boot manager invokes elilo, argc is 0,
while Optind is initialized to 1. If we continue with prompting
disabled, strange things can happen. (usually, attempts to boot
a non-existant kernel.)

Bill

--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-2.5-prompt.patch"

diff -ru gnu-efi-2.5/elilo/elilo.c ook/elilo/elilo.c
--- elilo/elilo.c	Mon May 21 17:58:56 2001
+++ elilo/elilo.c	Tue Jun  5 14:02:04 2001
@@ -373,7 +381,7 @@
 	 * if user specified a kernel name or label, then ignore
 	 * forced interactive mode
 	 */
-	if (argv[Optind]) elilo_opt.prompt = 0;
+	if (argv[Optind] && Optind <= argc) elilo_opt.prompt = 0;
 
 	/*
 	 * which chooser we will use 

--pf9I7BMVVzbSWLtt--

