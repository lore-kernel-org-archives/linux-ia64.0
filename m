From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 23 Jul 2001 14:09:19 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005869@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Martin" = Martin Wilck <Martin.Wilck@fujitsu-siemens.com> writes:

Martin> David's last patch assigns the system call number 1215 to
Martin> "getunwind".  The XFS kernel patch for 2.4.5 vuses 1215-1217
Martin> for address control lists.  How should this conflict be
Martin> resolved? For now, I have just made XFS use 1216-1218 instead.

Please don't do this. If you want to use temporary numbers, bump them
out of range so we don't clash with them in the next kernel
release. I'd say pick something like 8000 for now.

Jes

