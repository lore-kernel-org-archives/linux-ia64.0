From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 02 Aug 2001 20:18:45 +0000
Subject: Re: [Linux-ia64] efibootmgr-0.3.3-test5
Message-Id: <marc-linux-ia64-105590693005993@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt,

We have noticed (during RH7.1) install that efibootmgr was not checking
for options with an identical names and it was creating menu options
with the same name for instance if you reinstall the system a second time.


Would it be possible to add a warning/error/check that would avoid such a
thing ?

Thanks.

-- 
-Stephane

