From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Mon, 23 Jul 2001 13:53:06 +0000
Subject: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005867@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David's last patch assigns the system call number 1215 to "getunwind".
The XFS kernel patch for 2.4.5 vuses 1215-1217 for address control lists.
How should this conflict be resolved? For now, I have just made XFS use
1216-1218 instead.

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




