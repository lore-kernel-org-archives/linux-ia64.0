From: Bill Nottingham <notting@redhat.com>
Date: Fri, 13 Jul 2001 15:34:55 +0000
Subject: [Linux-ia64] Re: Red Hat Linux 7.1 for Itanium now available - Release Notes
Message-Id: <marc-linux-ia64-105590693005849@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005841@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005841@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dunn, Jesse (jesse.dunn@intel.com) said: 
> I am trying to install 7.1 on Lion, but I am getting this error message
> after the selecting custom installation, the message is "An error
> occured-novalid devices were found on which to create new file systems.
> Please check your hardware for the causse of this problem"
> 
> Does any one know what the problem is?

It didn't find any drives on your system. Did it probe the SCSI
bus OK?

Bill

