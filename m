From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 29 May 2003 01:37:52 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706064@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 28 May 2003 19:34:01 -0600, 
Bjorn Helgaas <bjorn_helgaas@hp.com> wrote:
>On Wednesday 28 May 2003 6:07 pm, Keith Owens wrote:
>> >+#define CPUSTR "cpu%d"
>> >+	char name[sizeof(CPUSTR)];
>> 
>> Too small.  name[] will overflow at cpu 100.
>
>Thanks.  I remember thinking about that when I copied the code,
>but forgot to fix it.  How about something like this:
>+	char cpustr[sizeof(CPUSTR) + 2];

That will do until we go past cpu 9,999.  "10,000 cpus should be enough
for anybody" :)


