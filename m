From: Mario Smarduch <cms063@email.mot.com>
Date: Tue, 26 Nov 2002 15:34:28 +0000
Subject: Re: [Linux-ia64] IA64 IPMI RCMP Libraries
Message-Id: <marc-linux-ia64-105590709805483@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805462@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805462@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In the initial email there was a mistake as shown by the puzzled
email response. Instead of RCMP the inquiry is referring to RMCP
(Remote Management Control Protocol) interface defined in
ch12 of IPMI v1.5 spec.

- Mario.


Christian Cotte-Barrot wrote:

> Mario Smarduch wrote:
> >
> > Has anyone ported any open source IPMI RCMP libraries onto
> > IA64. The functionality of interest is communication with a
> > chassis mgmt BMC in order to interrogate SDRs, FRU info,
> > trap events and manage the chassis including its components.
> >
> > Any info greatly appreciated.
> >
> > - mario.
> >
>
> Hi mario,
>
> Sorry for my delayed response.
>
> I don't know what are RCMP libraries (what acronym is it for) ?
> Some time ago I have written sources to implement user commands to
> interrogate FRU's and SEL's.
> These commands can be run on Asuza, Lion and Tiger systems and they
> rely on the Intel IPMI driver (imb).
>
> --
> ==================================
> |  |+AFw-/+AFw-/+AFw-/| |                       |                                  |
> |  |      | |Christian Cotte-Barrot |org.  :BULL/                      |
> |  | (+AH4-)(o) |Bull S.A.              |office:FREC/B1-401                |
> | C      _) |1, rue de Provence     |mailto:                           |
> |  | ,___|  |B.P. 208               |   Christian.Cotte-Barrot@bull.net|
> |  |   /    |38432 ECHIROLLES CEDEX |phone : (0)476297725 (229 7725)|
> | /----+AFw-    |FRANCE                 |fax   : (0)476297891 (229 7891)|
> ==================================


