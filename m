From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 29 May 2003 00:07:15 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706061@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 28 May 2003 17:26:02 -0600, 
Bjorn Helgaas <bjorn_helgaas@hp.com> wrote:
>+#define CPUSTR "cpu%d"
>+	char name[sizeof(CPUSTR)];

Too small.  name[] will overflow at cpu 100.


