From: Richard Hirst <rhirst@linuxcare.com>
Date: Mon, 06 Aug 2001 15:10:03 +0000
Subject: Re: [Linux-ia64] efibootmgr-0.3.3 release
Message-Id: <marc-linux-ia64-105590693006001@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693006000@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693006000@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 03, 2001 at 05:21:36PM -0500, Matt_Domsch@Dell.com wrote:
> New release efibootmgr 0.3.3 is now available at
> http://domsch.com/linux/ia64/efibootmgr-0.3.3.tar.gz.

Goes bang for me...  assuming efichar_strlen() is supposed to return
the length in efichars, not bytes, the following fixes it.  In any case
a null is needed on the end of buffer[].

Richard


--- efibootmgr-0.3.3/src/lib/efichar.c-	Mon Aug  6 16:48:40 2001
+++ efibootmgr-0.3.3/src/lib/efichar.c	Mon Aug  6 16:54:29 2001
@@ -36,11 +36,12 @@
 	char *buffer;
 	int s2_len = efichar_strlen(s2, -1);
 	
-	buffer = malloc(s2_len / sizeof(efi_char16_t));
+	buffer = malloc(s2_len+1);
 	if (!buffer) return -1;
 	for (i=0; i<(s2_len); i++) {
 		buffer[i] = s2[i] & 0xFF;
 	}
+	buffer[i] = '\0';
 	rc = strcmp(s1, buffer);
 	free(buffer);
 	return rc;

