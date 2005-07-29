From: david mosberger <dmosberger@gmail.com>
Date: Fri, 29 Jul 2005 18:22:04 +0000
Subject: Re: [PATCH] /proc/iomem update
Message-Id: <ed5aea43050729112247944246@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1DyZJE-0006Au-00@lyra.fc.hp.com>
In-Reply-To: <E1DyZJE-0006Au-00@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is the "continue" here spurious?  If not, it would cause
memory-leaking since "res" has been allocated already.

+                       case EFI_MEMORY_MAPPED_IO:
+                       case EFI_MEMORY_MAPPED_IO_PORT_SPACE:
+                               continue;
+                               break;

  --david
-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
