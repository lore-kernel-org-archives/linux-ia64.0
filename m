From: Keith Owens <kaos@sgi.com>
Date: Tue, 05 Oct 2004 01:42:08 +0000
Subject: Re: [patch 0/5 salinfo-0.6] summary
Message-Id: <3546.1096940528@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <11145.1096870990@kao2.melbourne.sgi.com>
In-Reply-To: <11145.1096870990@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 4 Oct 2004 10:02:18 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>By the way, I hear grumbling from neighboring cubes about
>the colons in the log file names, because it makes it hard
>to move the files to Windows (HP's log analysis tools are
>Windows-based).
>
>How much of a hassle would it be if we changed the colons
>to underscores or something?

Windows - yuck!

Do you want to add this to 0.6 or bump the version to 0.7?

Index: salinfo-0.6/salinfo_decode.c
=================================--- salinfo-0.6.orig/salinfo_decode.c	Mon Oct  4 16:04:03 2004
+++ salinfo-0.6/salinfo_decode.c	Tue Oct  5 10:49:38 2004
@@ -260,7 +260,7 @@ talk_to_sal (const char *type, const cha
 
 		for (suffix = 0; ; ++suffix) {
 			snprintf(filename, sizeof(filename),
-				"%s/raw/%02x%02x-%02x-%02x-%02x:%02x:%02x-cpu%d-%s.%d",
+				"%s/raw/%02x%02x-%02x-%02x-%02x_%02x_%02x-cpu%d-%s.%d",
 				directory,
 				buffer->timestamp.slh_century,
 				buffer->timestamp.slh_year,
@@ -291,7 +291,7 @@ talk_to_sal (const char *type, const cha
 		close(fd);
 
 		snprintf(filename, sizeof(filename),
-			"%s/decoded/%02x%02x-%02x-%02x-%02x:%02x:%02x-cpu%d-%s.%d",
+			"%s/decoded/%02x%02x-%02x-%02x-%02x_%02x_%02x-cpu%d-%s.%d",
 			directory,
 			buffer->timestamp.slh_century,
 			buffer->timestamp.slh_year,

