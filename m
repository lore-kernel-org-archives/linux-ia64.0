From: Sane_Purushottam@emc.com
Date: Wed, 25 Sep 2002 18:18:51 +0000
Subject: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906051@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have a linux application running on 32-bit machines. Due to some
third-party limitations, we cannot build this application on 64-bit machines
natively. Thus we'll be using the '32-bit compatibility mode'.

For some application specific reasons, I need to be able to determine at
run-time whether the application is running on a 32-bit or a 64-bit
platform.

What I have found is that there's no reliable way for the application to
determine whether it's running on a 64-bit machine. I use info obtained from
/proc/cpuinfo (more specifically family field) to determine the platform.
However this is not standard. On Redhat 7.1 (lk 2.4.3-12) family value is
set to IA-64 while on Redhat 7.2 (lk 2.4.9-34) this field is set to
'Itanium'.

What is the preferred method to determine the platform at run time ?? Are
these values likely to change (after I change my code to handle this) ????

Nitin Sane
sane_purushottam@emc.com
(508) 382-7319


