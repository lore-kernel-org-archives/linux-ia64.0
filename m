From: Jan Schreckenbach <Jan.Schreckenbach@sap.com>
Date: Mon, 18 Jun 2001 13:18:39 +0000
Subject: [Linux-ia64] eepro100 and nfs - mission impossible ?
Message-Id: <marc-linux-ia64-105590693005736@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

the problems with the eepro100 driver in conjunction with NFS
driving me mad. I'm using NFS very heavy for compiling and installing
(both: autofs and hand mounted shares).
Processes often hanging while accessing files on NFS shares (I have
seen a cp process hanging after aprox. 100MB on exactly the same point 
of the file, regardless how often I tried). 
I use Lion's with BIOS 76 with the latest SuSE and Red Hat distros. 
The e100 driver does not work as well.
Are there any chances to get it running???

cu,
Jan

--
_______________________________________________________________________

THE BEST RUN E-BUSINESSES RUN SAP
_______________________________________________________________________

Jan Schreckenbach                      email: Jan.Schreckenbach@sap.com
SAP AG Walldorf/Baden, Germany         Phone: +49 6227  7-47474
LinuxLab                               Fax  : +49 6227 78-31414

SAP LinuxLab support address: linux@sap.com

