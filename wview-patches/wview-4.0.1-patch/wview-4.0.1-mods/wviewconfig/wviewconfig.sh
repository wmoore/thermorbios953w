################################################################################
#
# File:           wviewconfig.sh
#
# Description:    Provide a script to interactively configure a wview 
#                 installation.
#
# Usage:          (must be root)
#                 wviewconfig
#                 wviewconfig get
#                 wviewconfig set [new_config_path]
#
# History:
# Engineer	  Date	    Ver   Comments
# MS Teel	  06/20/05   1    Original
# J Barber	  02/24/06   2    Partitioned into functions; added get/set
# MS Teel	  02/25/06   3    Tweaked arg and function names
# MS Teel     06/21/08   4    Better station type support
#
################################################################################


################################################################################
#################################  M A C R O S  ################################
################################################################################
WVIEWD_PID=/var/wview/wviewd.pid
CFG_STATION_TYPE=$STATION_TYPE

################################################################################
#######################  D E F I N E  F U N C T I O N S  #######################
################################################################################

show_usage()
{
    echo ""
    echo "wviewconfig"
    echo "    Configures wview interactively"
    echo "wviewconfig get"
    echo "    Prints current settings to stdout"
    echo "wviewconfig set [new_config_path]"
    echo "    Takes configuration at [new_config_path] and applies to wview configuration"
    echo ""
}

set_non_vp_defaults()
{
    if [ "" = "$STATION_ELEVATION" ]; then
        STATION_ELEVATION=changeME
    fi
    if [ "" = "$STATION_LATITUDE" ]; then
        STATION_LATITUDE=changeME
    fi
    if [ "" = "$STATION_LONGITUDE" ]; then
        STATION_LONGITUDE=changeME
    fi
    if [ "" = "$STATION_ARCHIVE_INTERVAL" ]; then
        STATION_ARCHIVE_INTERVAL=5
    fi
}

get_current()
{
    if [ "$METHOD" = "set" ]
    then
        # get settings for all parts of wview from single file 
        . $SET_FILE
    else
        # get settings from individual files
        if [ -f $WVIEW_CONF_DIR/wview.conf ]
        then
            . $WVIEW_CONF_DIR/wview.conf
            if [ "x$CFG_STATION_TYPE" != "x" ]; then
                STATION_TYPE=$CFG_STATION_TYPE
            fi
        fi

        if [ -f $WVIEW_CONF_DIR/htmlgen.conf ]
        then
            . $WVIEW_CONF_DIR/htmlgen.conf
        fi

        if [ -f $WVIEW_CONF_DIR/http.conf ]
        then
            . $WVIEW_CONF_DIR/http.conf
        fi

        if [ -f $WVIEW_CONF_DIR/wvcwop.conf ]
        then
            . $WVIEW_CONF_DIR/wvcwop.conf
        fi
    fi

    # If STATION_TYPE is not set, default to VantagePro:
    if [ "$STATION_TYPE" = "" ]; then
        # We default to VantagePro
        STATION_TYPE=VantagePro
    fi

    # Try to obtain the current values (if found) to use for the default choices
    if [ "" = "$POLL_INTERVAL" ]; then
        POLL_INTERVAL=15000
    fi
    
    # Station-specific initialization:
    case "$STATION_TYPE" in
        "VantagePro" )
            if [ "" = "$DO_RXCHECK" ]; then
                DO_RXCHECK=1
            fi
        ;;
        "Simulator" )
            set_non_vp_defaults
        ;;
        "WXT510" )
            set_non_vp_defaults
        ;;
        "WS-2300" )
            set_non_vp_defaults
        ;;
        "WMR918" )
            set_non_vp_defaults
        ;;
        "BW9xx" )
            set_non_vp_defaults
        ;;
    esac

} # end of get_current

set_default()
{
    # if values were not found in the existing conf files, use some logical
    # default values
    if [ "" = "$STATION_INTERFACE" ]; then
        STATION_INTERFACE=serial
    fi
    if [ "" = "$STATION_DEV" ]; then
        STATION_DEV=/dev/ttyS0
    fi
    if [ "" = "$STATION_HOST" ]; then
        STATION_HOST=changeME
    fi
    if [ "" = "$STATION_PORT" ]; then
        STATION_PORT=changeME
    fi
    if [ "" = "$STATION_RAIN_SEASON_START" ]; then
        STATION_RAIN_SEASON_START=1
    fi
    if [ "" = "$STATION_RAIN_STORM_TRIGGER_START" ]; then
        STATION_RAIN_STORM_TRIGGER_START=0.05
    fi
    if [ "" = "$STATION_RAIN_STORM_IDLE_STOP" ]; then
        STATION_RAIN_STORM_IDLE_STOP=12
    fi
    if [ "" = "$STATION_RAIN_YTD" ]; then
        STATION_RAIN_YTD=0
    fi
    if [ "" = "$STATION_ET_YTD" ]; then
        STATION_ET_YTD=0
    fi
    if [ "" = "$STATION_RAIN_ET_YTD_YEAR" ]; then
        STATION_RAIN_ET_YTD_YEAR=0
    fi
    if [ "" = "$ARCHIVE_PATH" ]; then
        ARCHIVE_PATH=$WVIEW_DATA_DIR/archive
    fi
    if [ "" = "$POLL_INTERVAL" ]; then
        POLL_INTERVAL=15000
    fi
    if [ "" = "$PUSH_INTERVAL" ]; then
        PUSH_INTERVAL=60000
    fi
    if [ "" = "$VERBOSE_MSGS" ]; then
        VERBOSE_MSGS=00000011
    fi

    if [ "" = "$SQLDB_ENABLE" ]; then
        SQLDB_ENABLE=0
    fi
    if [ "" = "$SQLDB_EXTENDED_INFO" ]; then
        SQLDB_EXTENDED_INFO=0
    fi
    if [ "" = "$SQLDB_STORE_METRIC" ]; then
        SQLDB_STORE_METRIC=0
    fi
    if [ "" = "$SQLDB_HOST" ]; then
        SQLDB_HOST=changeME
    fi
    if [ "" = "$SQLDB_USERNAME" ]; then
        SQLDB_USERNAME=changeME
    fi
    if [ "" = "$SQLDB_PASSWORD" ]; then
        SQLDB_PASSWORD=changeME
    fi
    if [ "" = "$SQLDB_DB_NAME" ]; then
        SQLDB_DB_NAME=wviewDB
    fi
    if [ "" = "$SQLDB_TABLE_NAME" ]; then
        SQLDB_TABLE_NAME=archive
    fi
    if [ "" = "$SQLDB_FULL_SYNC" ]; then
        SQLDB_FULL_SYNC=1
    fi
    
    if [ "" = "$STATION_NAME" ]; then
        STATION_NAME=changeME
    fi
    if [ "" = "$STATION_CITY" ]; then
        STATION_CITY=changeME
    fi
    if [ "" = "$STATION_STATE" ]; then
        STATION_STATE=changeME
    fi
    if [ "" = "$IMAGE_PATH" ]; then
        IMAGE_PATH=$WVIEW_DATA_DIR/img
    fi
    if [ "" = "$HTML_PATH" ]; then
        HTML_PATH=$WVIEW_CONF_DIR/html
    fi
    if [ "" = "$START_OFFSET" ]; then
        START_OFFSET=0
    fi
    if [ "" = "$GENERATE_INTERVAL" ]; then
        GENERATE_INTERVAL=1
    fi
    if [ "" = "$METRIC_UNITS" ]; then
        METRIC_UNITS=0
    fi
    if [ "" = "$METRIC_USE_RAIN_MM" ]; then
        METRIC_USE_RAIN_MM=1
    fi
    if [ "" = "$DUAL_UNITS" ]; then
        DUAL_UNITS=0
    fi
    if [ "" = "$EXTENDED_DATA" ]; then
        EXTENDED_DATA=0
    fi
    if [ "" = "$ARCHIVE_BROWSER_FILES_TO_KEEP" ]; then
        ARCHIVE_BROWSER_FILES_TO_KEEP=3
    fi
    if [ "" = "$MPHASE_INCREASE" ]; then
        MPHASE_INCREASE=Waxing
    fi
    if [ "" = "$MPHASE_DECREASE" ]; then
        MPHASE_DECREASE=Waning
    fi
    if [ "" = "$MPHASE_FULL" ]; then
        MPHASE_FULL=Full
    fi
    if [ "" = "$LOCAL_RADAR_URL" ]; then
        LOCAL_RADAR_URL=http://www.srh.noaa.gov/radar/images/DS.p19r0/SI.kfws/latest.gif
    fi
    if [ "" = "$LOCAL_FORECAST_URL" ]; then
        LOCAL_FORECAST_URL=http://www.wunderground.com/cgi-bin/findweather/getForecast?query=76233
    fi
    
    if [ "" = "$APRS_CALL_SIGN" ]; then
        APRS_CALL_SIGN=changeME
    fi
    if [ "" = "$APRS_SERVER1" ]; then
        APRS_SERVER1=cwop.aprs.net
    fi
    if [ "" = "$APRS_PORTNO1" ]; then
        APRS_PORTNO1=23
    fi
    if [ "" = "$APRS_SERVER2" ]; then
        APRS_SERVER2=second.aprs.net
    fi
    if [ "" = "$APRS_PORTNO2" ]; then
        APRS_PORTNO2=14580
    fi
    if [ "" = "$APRS_SERVER3" ]; then
        APRS_SERVER3=third.aprs.net
    fi
    if [ "" = "$APRS_PORTNO3" ]; then
        APRS_PORTNO3=14580
    fi
    if [ "" = "$LATITUDE" ]; then
        LATITUDE=changeME
    fi
    if [ "" = "$LONGITUDE" ]; then
        LONGITUDE=changeME
    fi
    if [ "" = "$LOG_WX_PACKET" ]; then
        LOG_WX_PACKET=0
    fi
    
    if [ "" = "$STATIONID" ]; then
        STATIONID=changeME
    fi
    if [ "" = "$PASSWORD" ]; then
        PASSWORD=changeME
    fi
    if [ "" = "$YOUSTATIONID" ]; then
        YOUSTATIONID=changeME
    fi
    if [ "" = "$YOUPASSWORD" ]; then
        YOUPASSWORD=changeME
    fi
    if [ "" = "$DATE_FORMAT" ]; then
        if [ "0" = "$METRIC_UNITS" ]
        then
            DATE_FORMAT=%D
        else
            DATE_FORMAT=%Y%m%d
        fi
    fi
} #end of set_default

print_current()
{
    echo STATION_TYPE=$STATION_TYPE
    echo STATION_INTERFACE=$STATION_INTERFACE
    echo STATION_DEV=$STATION_DEV
    echo STATION_HOST=$STATION_HOST
    echo STATION_PORT=$STATION_PORT
    echo STATION_RAIN_SEASON_START=$STATION_RAIN_SEASON_START
    echo STATION_RAIN_STORM_TRIGGER_START=$STATION_RAIN_STORM_TRIGGER_START
    echo STATION_RAIN_STORM_IDLE_STOP=$STATION_RAIN_STORM_IDLE_STOP
    echo STATION_RAIN_YTD=$STATION_RAIN_YTD
    echo STATION_ET_YTD=$STATION_ET_YTD
    echo STATION_RAIN_ET_YTD_YEAR=$STATION_RAIN_ET_YTD_YEAR
    echo ARCHIVE_PATH=$ARCHIVE_PATH
    echo POLL_INTERVAL=$POLL_INTERVAL
    echo PUSH_INTERVAL=$PUSH_INTERVAL
    echo VERBOSE_MSGS=$VERBOSE_MSGS
    echo DO_RXCHECK=$DO_RXCHECK
    echo STATION_ELEVATION=$STATION_ELEVATION
    echo STATION_LATITUDE=$STATION_LATITUDE
    echo STATION_LONGITUDE=$STATION_LONGITUDE
    echo STATION_ARCHIVE_INTERVAL=$STATION_ARCHIVE_INTERVAL
    echo SQLDB_ENABLE=$SQLDB_ENABLE
    echo SQLDB_EXTENDED_INFO=$SQLDB_EXTENDED_INFO
    echo SQLDB_STORE_METRIC=$SQLDB_STORE_METRIC
    echo SQLDB_HOST=$SQLDB_HOST
    echo SQLDB_USERNAME=$SQLDB_USERNAME
    echo SQLDB_PASSWORD=$SQLDB_PASSWORD
    echo SQLDB_DB_NAME=$SQLDB_DB_NAME
    echo SQLDB_TABLE_NAME=$SQLDB_TABLE_NAME
    echo SQLDB_FULL_SYNC=$SQLDB_FULL_SYNC
    echo STATION_NAME=$STATION_NAME
    echo STATION_CITY=$STATION_CITY
    echo STATION_STATE=$STATION_STATE
    echo IMAGE_PATH=$IMAGE_PATH
    echo HTML_PATH=$HTML_PATH
    echo START_OFFSET=$START_OFFSET
    echo GENERATE_INTERVAL=$GENERATE_INTERVAL
    echo METRIC_UNITS=$METRIC_UNITS
    echo METRIC_USE_RAIN_MM=$METRIC_USE_RAIN_MM
    echo DUAL_UNITS=$DUAL_UNITS
    echo EXTENDED_DATA=$EXTENDED_DATA
    echo ARCHIVE_BROWSER_FILES_TO_KEEP=$ARCHIVE_BROWSER_FILES_TO_KEEP
    echo MPHASE_INCREASE=$MPHASE_INCREASE
    echo MPHASE_DECREASE=$MPHASE_DECREASE
    echo MPHASE_FULL=$MPHASE_FULL
    echo APRS_CALL_SIGN=$APRS_CALL_SIGN
    echo APRS_SERVER1=$APRS_SERVER1
    echo APRS_PORTNO1=$APRS_PORTNO1
    echo APRS_SERVER2=$APRS_SERVER2
    echo APRS_PORTNO2=$APRS_PORTNO2
    echo APRS_SERVER3=$APRS_SERVER3
    echo APRS_PORTNO3=$APRS_PORTNO3
    echo LATITUDE=$LATITUDE
    echo LONGITUDE=$LONGITUDE
    echo LOG_WX_PACKET=$LOG_WX_PACKET
    echo STATIONID=$STATIONID
    echo PASSWORD=$PASSWORD
    echo YOUSTATIONID=$YOUSTATIONID
    echo YOUPASSWORD=$YOUPASSWORD
    echo LOCAL_FORECAST_URL=$LOCAL_FORECAST_URL
    echo LOCAL_RADAR_URL=$LOCAL_RADAR_URL
    echo DATE_FORMAT=$DATE_FORMAT
} #end of print_current

write_wview_conf()
{
    # Write out the conf file:
    echo ""
    if [ -f $WVIEW_CONF_DIR/wview.conf ]; then
        echo "Moving existing $WVIEW_CONF_DIR/wview.conf to $WVIEW_CONF_DIR/wview.conf.old..."
        mv $WVIEW_CONF_DIR/wview.conf $WVIEW_CONF_DIR/wview.conf.old
    fi
    echo ""
    echo -n "Writing $WVIEW_CONF_DIR/wview.conf: "
    mkdir -p $WVIEW_CONF_DIR
    
    echo "#@" > $WVIEW_CONF_DIR/wview.conf
    echo "#"  >> $WVIEW_CONF_DIR/wview.conf
    echo "#  This file contains configuration information for the wview wviewd daemon."  >> $WVIEW_CONF_DIR/wview.conf
    echo "#"  >> $WVIEW_CONF_DIR/wview.conf
    echo "#  Note: For parameters that enable/disable a feature, a value of 0 disables"  >> $WVIEW_CONF_DIR/wview.conf
    echo "#        the feature and 1 enables it..."  >> $WVIEW_CONF_DIR/wview.conf
    echo "#"  >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    echo "##################### Station Configuration      #####################"  >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    echo "# Station type -"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# one of Simulator, VantagePro, WXT510, WS-2300, WMR918, BW9xx:"  >> $WVIEW_CONF_DIR/wview.conf
    echo "STATION_TYPE=$STATION_TYPE" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    echo "# Physical interface to the weather station -"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# one of serial or ethernet:"  >> $WVIEW_CONF_DIR/wview.conf
    echo "STATION_INTERFACE=$STATION_INTERFACE" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    # the next few depend on the medium selected
    if [ "$STATION_INTERFACE" = "serial" ]; then
        echo "# Weather station serial device:"  >> $WVIEW_CONF_DIR/wview.conf
        echo "STATION_DEV=$STATION_DEV" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    elif [ "$STATION_INTERFACE" = "ethernet" ]; then
        echo "# Terminal server hostname/IP:"  >> $WVIEW_CONF_DIR/wview.conf
        echo "STATION_HOST=$STATION_HOST" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
        echo "# Terminal server TCP port to the weather station:"  >> $WVIEW_CONF_DIR/wview.conf
        echo "STATION_PORT=$STATION_PORT" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    fi
    
    echo "# Station rain season start month (1 - 12):"  >> $WVIEW_CONF_DIR/wview.conf
    echo "STATION_RAIN_SEASON_START=$STATION_RAIN_SEASON_START" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Station rain storm start trigger (rainfall rate in inches/hour):"  >> $WVIEW_CONF_DIR/wview.conf
    echo "STATION_RAIN_STORM_TRIGGER_START=$STATION_RAIN_STORM_TRIGGER_START" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Station rain storm stop time (hours without any rainfall which will end the storm):"  >> $WVIEW_CONF_DIR/wview.conf
    echo "STATION_RAIN_STORM_IDLE_STOP=$STATION_RAIN_STORM_IDLE_STOP" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Station rain Year-To-Date preset (to include rain not in archive records) (x.yy inches, 0 disables):"  >> $WVIEW_CONF_DIR/wview.conf
    echo "STATION_RAIN_YTD=$STATION_RAIN_YTD" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Station ET Year-To-Date preset (to include ET not in archive records) (x.yyy inches, 0 disables):"  >> $WVIEW_CONF_DIR/wview.conf
    echo "STATION_ET_YTD=$STATION_ET_YTD" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Station rain/ET preset year (rain season start year that presets should apply) (2000-present year, 0 disables):"  >> $WVIEW_CONF_DIR/wview.conf
    echo "STATION_RAIN_ET_YTD_YEAR=$STATION_RAIN_ET_YTD_YEAR" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    echo "##################### wviewd Configuration       #####################"  >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Where to store monthly Weather data archive files:"  >> $WVIEW_CONF_DIR/wview.conf
    echo "ARCHIVE_PATH=$ARCHIVE_PATH" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Weather station sensor poll interval (ms) - should be divisor of 60000:"  >> $WVIEW_CONF_DIR/wview.conf
    echo "POLL_INTERVAL=$POLL_INTERVAL" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Current conditions data push interval for wvalarmd and possibly others (ms):"  >> $WVIEW_CONF_DIR/wview.conf
    echo "PUSH_INTERVAL=$PUSH_INTERVAL" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Daemon Verbose Log Mask:"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 1 bit per daemon, 1 enables verbose logging, 0 disables"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# Bit definitions:"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 00000001     - wviewd"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 00000010     - htmlgend"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 00000100     - wvalarmd"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 00001000     - wviewftpd"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 00010000     - wviewsshd"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 00100000     - wvcwopd"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 01000000     - wvhttpd"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# 11111111     - All On"  >> $WVIEW_CONF_DIR/wview.conf
    echo "# Verbose diagnostic log messages per-daemon bitmask (8 characters, 0 or 1 only):"  >> $WVIEW_CONF_DIR/wview.conf
    echo "VERBOSE_MSGS=$VERBOSE_MSGS" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf

    # VantagePro Only
    if [ "$STATION_TYPE" = "VantagePro" ]; then
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
        echo "##################### Vantage Pro Configuration  #####################"  >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
        echo "# Generate RX check data (populate rxCheck.png chart)?"  >> $WVIEW_CONF_DIR/wview.conf
        echo "DO_RXCHECK=$DO_RXCHECK" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    fi

    # Non-VantagePro
    if [ "$STATION_TYPE" != "VantagePro" ]; then
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
        echo "##################### Generic Configuration      #####################"  >> $WVIEW_CONF_DIR/wview.conf
        echo "######## >For stations which do not maintain these settings< #########"  >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# Weather station elevation (feet above sea level):"  >> $WVIEW_CONF_DIR/wview.conf
        echo "STATION_ELEVATION=$STATION_ELEVATION" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# Weather station latitude (decimal degrees, NORTH is positive - SOUTH is negative):"  >> $WVIEW_CONF_DIR/wview.conf
        echo "STATION_LATITUDE=$STATION_LATITUDE" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# Weather station longitude (decimal degrees, EAST is positive - WEST is negative):"  >> $WVIEW_CONF_DIR/wview.conf
        echo "STATION_LONGITUDE=$STATION_LONGITUDE" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# DO NOT CHANGE this once you have archive records stored in /var/wview/archive!"  >> $WVIEW_CONF_DIR/wview.conf
        echo "# This effects many things (Wunderground update interval, etc.) so choose carefully..."  >> $WVIEW_CONF_DIR/wview.conf
        echo "# Weather data archive interval (minutes, one of 5, 10, 15, 30):"  >> $WVIEW_CONF_DIR/wview.conf
        echo "STATION_ARCHIVE_INTERVAL=$STATION_ARCHIVE_INTERVAL" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    fi
    
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    echo "##################### SQL Database Configuration #####################"  >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    echo "# Enable SQL DB archive storage?"  >> $WVIEW_CONF_DIR/wview.conf
    echo "SQLDB_ENABLE=$SQLDB_ENABLE" >> $WVIEW_CONF_DIR/wview.conf
    echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
    if [ "$SQLDB_ENABLE" = "1" ]; then
        echo "--Note-- Probably not supported unless you have installed extra sensors or have a VP Plus:"
        echo "Should wviewd store extended sensor archive data in the database (0 or 1)?"
        echo "SQLDB_EXTENDED_INFO=$SQLDB_EXTENDED_INFO" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# Store metric values in the database?"  >> $WVIEW_CONF_DIR/wview.conf
        echo "SQLDB_STORE_METRIC=$SQLDB_STORE_METRIC" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# DB server hostname or IP address:"  >> $WVIEW_CONF_DIR/wview.conf
        echo "SQLDB_HOST=$SQLDB_HOST" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# DB server username:"  >> $WVIEW_CONF_DIR/wview.conf
        echo "SQLDB_USERNAME=$SQLDB_USERNAME" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# DB server password:"  >> $WVIEW_CONF_DIR/wview.conf
        echo "SQLDB_PASSWORD=$SQLDB_PASSWORD" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# Database name where archive records are stored:"  >> $WVIEW_CONF_DIR/wview.conf
        echo "SQLDB_DB_NAME=$SQLDB_DB_NAME" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    
        echo "# DB table name where archive records are stored:"  >> $WVIEW_CONF_DIR/wview.conf
        echo "SQLDB_TABLE_NAME=$SQLDB_TABLE_NAME" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf

        echo "# Full database sync (0 or 1)"  >> $WVIEW_CONF_DIR/wview.conf
        echo "SQLDB_FULL_SYNC=$SQLDB_FULL_SYNC" >> $WVIEW_CONF_DIR/wview.conf
        echo ""  >> $WVIEW_CONF_DIR/wview.conf
    fi
    
    echo "done!"
    echo ""
    echo ""
} #end of write_wview_conf

interactive_intro()
{
    echo "################################################################################"
    echo " !!!!!!!!!!!!!!!!         READ THIS BEFORE PROCEEDING         !!!!!!!!!!!!!!!!"
    echo ""
    echo "--> System Configuration for wview"
    echo ""
    echo "--> Values in parenthesis are your existing values (if they exist) or defaults - "
    echo "    they will be used if you just hit enter at the prompt..."
    echo ""
    echo "--> Note: This script will save existing wview.conf, htmlgen.conf, wvcwop.conf"
    echo "          and http.conf files to $WVIEW_CONF_DIR/*.old before writing the new files" 
    echo "          based on your answers here - if that is not what you want, hit CTRL-C now to"
    echo "          abort this script!"
    echo ""
    echo "################################################################################"
    echo ""
    echo -n "pausing 3 seconds "
    sleep 1
    echo -n "."
    sleep 1
    echo -n "."
    sleep 1
    echo "."
    echo ""
} # end of interactive_intro


get_wview_conf_interactive()
{
    # determine what kind of station they have built for...
    echo "-------------------------------------------------------------"
    echo "Valid Station Types: VantagePro, Simulator, WXT510, WS-2300, WMR918, BW9xx"
    echo "What weather station do you have (one of VantagePro, Simulator, WXT510, WS-2300, WMR918, BW9xx):"
    echo -n "($STATION_TYPE): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        STATION_TYPE=$INVAL
    fi
    
    # verify the station type
    if [ "$STATION_TYPE" != "VantagePro" ]; then
        if [ "$STATION_TYPE" != "Simulator" ]; then
            if [ "$STATION_TYPE" != "WXT510" ]; then
                if [ "$STATION_TYPE" != "WS-2300" ]; then
                    if [ "$STATION_TYPE" != "WMR918" ]; then
                    	if [ "$STATION_TYPE" != "BW9xx" ]; then
                        echo "Invalid station type $STATION_TYPE given, try again!"
                        exit 1
						fi
                    fi
                fi
            fi
        fi
    fi

    echo "################################################################################"
    echo "--> wviewd Configuration ($WVIEW_CONF_DIR/wview.conf):"
    echo ""
    
    # All but Simulator:
    if [ "$STATION_TYPE" != "Simulator" ]; then
        echo "-------------------------------------------------------------" 
        echo "--Note-- USB is considered serial (/dev/ttyUSBx, /dev/tty.SLAB_USBtoUART, etc.)"
        echo "Physical Interface the weather station is connected to (one of serial or ethernet)"
        echo -n "($STATION_INTERFACE): "
        read INVAL
        if [ "" != "$INVAL" ]; then
            STATION_INTERFACE=$INVAL
        fi
        
        # the next few depend on the medium selected
        if [ "$STATION_INTERFACE" = "serial" ]; then
            echo ""
            echo "-------------------------------------------------------------" 
            echo "Serial port (device) the weather station is connected to (/dev/ttyS0, /dev/cuaa0, /dev/ttyUSBx, /dev/tty.SLAB_USBtoUART, etc.)"
            echo -n "($STATION_DEV): "
            read INVAL
            if [ "" != "$INVAL" ]; then
                STATION_DEV=$INVAL
            fi
        elif [ "$STATION_INTERFACE" = "ethernet" ]; then
            echo ""
            echo "-------------------------------------------------------------" 
            echo "Hostname or IP address the weather station is connected to (i.e. xyplex1 or 10.11.12.13)"
            echo -n "($STATION_HOST): "
            read INVAL
            if [ "" != "$INVAL" ]; then
                STATION_HOST=$INVAL
            fi
        
            echo ""
            echo "-------------------------------------------------------------" 
            echo "--Note-- This is dependent upon the terminal server used - consult your terminal server documentation"
            echo "TCP port the weather station is connected to on $STATION_HOST (i.e. 2101)"
            echo -n "($STATION_PORT): "
            read INVAL
            if [ "" != "$INVAL" ]; then
                STATION_PORT=$INVAL
            fi
        else
            echo "$STATION_INTERFACE is not a valid physical interface - must be one of serial or ethernet!"
            exit 7
        fi
    fi

    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station Rain Season Start Month (1 - 12):"
    echo -n "($STATION_RAIN_SEASON_START): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        STATION_RAIN_SEASON_START=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station rain storm start trigger (rainfall rate in inches/hour):"
    echo -n "($STATION_RAIN_STORM_TRIGGER_START): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        STATION_RAIN_STORM_TRIGGER_START=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station rain storm stop time (hours without any rainfall which will end the storm):"
    echo -n "($STATION_RAIN_STORM_IDLE_STOP): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        STATION_RAIN_STORM_IDLE_STOP=$INVAL
    fi

    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station rain Year-To-Date preset (to include rain not in archive records) (x.yy inches, 0 disables):"
    echo -n "($STATION_RAIN_YTD): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        STATION_RAIN_YTD=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station ET Year-To-Date preset (to include ET not in archive records) (x.yyy inches, 0 disables):"
    echo -n "($STATION_ET_YTD): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        STATION_ET_YTD=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station rain/ET preset year (rain season start year that presets should apply) (2000-present year, 0 disables):"
    echo -n "($STATION_RAIN_ET_YTD_YEAR): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        STATION_RAIN_ET_YTD_YEAR=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- Under normal circumstances, the default selection should be used"
    echo "Where to store archive files (*.wlk) - this must be local to the wview server"
    echo -n "($ARCHIVE_PATH): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        ARCHIVE_PATH=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- This value must be one of 10000, 15000 or 30000 (milliseconds)"
    echo "How often should wviewd poll the weather station for current conditions (milliseconds)?"
    echo -n "($POLL_INTERVAL): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        POLL_INTERVAL=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- This value must be >= 15000 (milliseconds)"
    echo "How often should wviewd provide current conditions data to clients such as wvalarmd (milliseconds)?"
    echo -n "($PUSH_INTERVAL): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        PUSH_INTERVAL=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- error messages are not affected by this setting"
    echo "Daemon Verbose Log Mask:"
    echo "1 bit per daemon, 1 enables verbose logging, 0 disables"
    echo "Bit definitions:"
    echo "00000001     - wviewd"
    echo "00000010     - htmlgend"
    echo "00000100     - wvalarmd"
    echo "00001000     - wviewftpd"
    echo "00010000     - wviewsshd"
    echo "00100000     - wvcwopd"
    echo "01000000     - wvhttpd"
    echo "11111111     - All On"
    echo "Verbose diagnostic log messages per-daemon bitmask (8 characters, 0 or 1 only):"
    echo -n "($VERBOSE_MSGS): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        VERBOSE_MSGS=$INVAL
    fi
    
    # VantagePro Only
    if [ "$STATION_TYPE" = "VantagePro" ]; then
        echo ""
        echo "-------------------------------------------------------------" 
        echo "--Note--  enabling this can occasionally cause serial IF problems -"
        echo "--Note--  if you are having WAKEUP console errors, try disabling this"
        echo "Should wview generate RX check data (populate rxCheck.png chart) (0 or 1)?"
        echo -n "($DO_RXCHECK): "
        read INVAL
        if [ "" != "$INVAL" ]; then
            DO_RXCHECK=$INVAL
        fi
    fi
    
    # Non-VP
    if [ "$STATION_TYPE" != "VantagePro" ]; then
        echo ""
        echo "-------------------------------------------------------------" 
        echo "Weather station elevation (feet above sea level)?"
        echo -n "($STATION_ELEVATION): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$STATION_ELEVATION" ]; then
                echo "Station elevation must be specified!"
                exit 8
            fi
        else
            STATION_ELEVATION=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "--Note--  This is given in decimal degrees NORTH (-90.00 to 90.00) -"
        echo "--Note--  Examples: -46.31 (46.31 degrees SOUTH), 33.4 (33.4 degrees NORTH)"
        echo "Weather station latitude?"
        echo -n "($STATION_LATITUDE): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$STATION_LATITUDE" ]; then
                echo "Station latitude must be specified!"
                exit 8
            fi
        else
            STATION_LATITUDE=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "--Note--  This is given in decimal degrees EAST (-179.99 to 180.00) -"
        echo "--Note--  Examples: -96.9 (96.9 degrees WEST), 112.71 (112.71 degrees EAST)"
        echo "Weather station longitude?"
        echo -n "($STATION_LONGITUDE): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$STATION_LONGITUDE" ]; then
                echo "Station longitude must be specified!"
                exit 8
            fi
        else
            STATION_LONGITUDE=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "--Note--  DO NOT CHANGE this once you have archive records stored in /var/wview/archive"
        echo "--Note--      unless you delete all *.wlk files first!"
        echo "--Note--  This effects many things (Wunderground update interval, etc.) so"
        echo "--Note--      choose it carefully and be prepared to stay with your choice!"
        echo "--Note--  If unsure what all this affects, CTRL-C to exit this script and do"
        echo "--Note--      a search for 'archive interval' in the wview User Manual..."
        echo "Weather data archive interval (minutes, one of 5, 10, 15, 30)?"
        echo -n "($STATION_ARCHIVE_INTERVAL): "
        read INVAL
        if [ "" != "$INVAL" ]; then
            STATION_ARCHIVE_INTERVAL=$INVAL
        fi
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- currently only MySQL and PostgreSQL are supported"
    echo "Should wviewd store archive data in a relational database (0 or 1)?"
    echo -n "($SQLDB_ENABLE): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        SQLDB_ENABLE=$INVAL
    fi
    
    if [ "$SQLDB_ENABLE" = "1" ]; then
        echo ""
        echo "-------------------------------------------------------------" 
        echo "--Note-- Probably not supported unless you have installed extra sensors or have a VP Plus"
        echo "Should wviewd store extended sensor archive data in the database (0 or 1)?"
        echo -n "($SQLDB_EXTENDED_INFO): "
        read INVAL
        if [ "" != "$INVAL" ]; then
            SQLDB_EXTENDED_INFO=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "Should wviewd store metric (international) archive data in the database (0 or 1)?"
        echo -n "($SQLDB_STORE_METRIC): "
        read INVAL
        if [ "" != "$INVAL" ]; then
            SQLDB_STORE_METRIC=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "Hostname or IP address of the database server:"
        echo -n "($SQLDB_HOST): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$SQLDB_HOST" ]; then
                echo "Database host or IP address must be specified!"
                exit 8
            fi
        else
            SQLDB_HOST=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "Username of the database server:"
        echo -n "($SQLDB_USERNAME): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$SQLDB_USERNAME" ]; then
                echo "Database username must be specified!"
                exit 8
            fi
        else
            SQLDB_USERNAME=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "Password for $SQLDB_USERNAME on the database server:"
        echo -n "($SQLDB_PASSWORD): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$SQLDB_PASSWORD" ]; then
                echo "Database password must be specified!"
                exit 8
            fi
        else
            SQLDB_PASSWORD=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "Database name for weather records on the database server:"
        echo -n "($SQLDB_DB_NAME): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$SQLDB_DB_NAME" ]; then
                echo "Database name must be specified!"
                exit 8
            fi
        else
            SQLDB_DB_NAME=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "Table name for weather records on the database server:"
        echo -n "($SQLDB_TABLE_NAME): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$SQLDB_TABLE_NAME" ]; then
                echo "Database table must be specified!"
                exit 8
            fi
        else
            SQLDB_TABLE_NAME=$INVAL
        fi

        echo ""
        echo "-------------------------------------------------------------" 
        echo "--Note--  0 starts sync from last record in database, which can be quicker"
        echo "--Note--  1 starts sync from first archive record, which will be thorough"
        echo "Full database sync (0 or 1):"
        echo -n "($SQLDB_FULL_SYNC): "
        read INVAL
        if [ "" != "$INVAL" ]; then
            SQLDB_FULL_SYNC=$INVAL
        fi
    fi
} # end of get_wview_conf_interactive

get_html_conf_interactive()
{
    echo "################################################################################"
    echo "--> HTML Configuration ($WVIEW_CONF_DIR/htmlgen.conf):"
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station Name (no spaces):"
    echo -n "($STATION_NAME): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$STATION_NAME" ]; then
            echo "Station Name must be specified!"
            exit 9
        fi
    else
        STATION_NAME=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station City (no spaces):"
    echo -n "($STATION_CITY): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$STATION_CITY" ]; then
            echo "Station City must be specified!"
            exit 9
        fi
    else
        STATION_CITY=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Station State (no spaces):"
    echo -n "($STATION_STATE): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$STATION_STATE" ]; then
            echo "Station State must be specified!"
            exit 9
        fi
    else
        STATION_STATE=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- If your web server is on the same machine as wview, this should be the "
    echo "--Note-- document root for your weather site. If you are going to ftp or ssh/rsync "
    echo "--Note-- your site to a remote web server (such as your ISP), please use the "
    echo "--Note-- default selection."
    echo "Where to store generated web site graphics and HTML files:"
    echo -n "($IMAGE_PATH): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        IMAGE_PATH=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- Normal installs should use the default selection"
    echo "Where to find HTML template files for web site generation:"
    echo -n "($HTML_PATH): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        HTML_PATH=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Generation start offset (0-4) in minutes past the 5-minute mark:"
    echo -n "($START_OFFSET): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        START_OFFSET=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Generation interval (refresh interval for your site data) (minutes):"
    echo -n "($GENERATE_INTERVAL): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        GENERATE_INTERVAL=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Enable metric conversion/units?"
    echo -n "($METRIC_UNITS): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        METRIC_UNITS=$INVAL
    fi
    
    if [ "0" != "$METRIC_UNITS" ]; then
        echo ""
        echo "-------------------------------------------------------------" 
        echo "Use mm for rain instead of cm?"
        echo -n "($METRIC_USE_RAIN_MM): "
        read INVAL
        if [ "" != "$INVAL" ]; then
            METRIC_USE_RAIN_MM=$INVAL
        fi
    fi

    echo ""
    echo "-------------------------------------------------------------------" 
    echo "--Note-- If set, this will display both metric and non-metric units"
    echo "Enable dual unit display?"
    echo -n "($DUAL_UNITS): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        DUAL_UNITS=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- Extended data must be supported by your station"
    echo "Store/process extended sensor values for site generation?"
    echo -n "($EXTENDED_DATA): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        EXTENDED_DATA=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- Each file contains one day's worth of archive records in ASCII format"
    echo "--Note-- Special Values: -1 disables archive browser file generation and 0 keeps all files"
    echo "How many archive record browser files to keep (days):"
    echo -n "($ARCHIVE_BROWSER_FILES_TO_KEEP): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        ARCHIVE_BROWSER_FILES_TO_KEEP=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Moon Phase increasing text (no spaces):"
    echo -n "($MPHASE_INCREASE): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        MPHASE_INCREASE=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Moon Phase decreasing text (no spaces):"
    echo -n "($MPHASE_DECREASE): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        MPHASE_DECREASE=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Moon Phase full text (no spaces):"
    echo -n "($MPHASE_FULL): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        MPHASE_FULL=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Local Radar URL (no spaces):"
    echo -n "($LOCAL_RADAR_URL): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        LOCAL_RADAR_URL=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "Local Forecast URL (no spaces):"
    echo -n "($LOCAL_FORECAST_URL): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        LOCAL_FORECAST_URL=$INVAL
    fi

    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- see 'man strftime' for allowable formats "
    echo "--Note-- underscores will be replaced by spaces in output "
    echo "Date format (no spaces): "
    echo -n "($DATE_FORMAT): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        DATE_FORMAT=$INVAL
    fi
} # end of get_html_conf_interactive

write_html_conf()
{
    # Write out the conf file:
    echo ""
    if [ -f $WVIEW_CONF_DIR/htmlgen.conf ]; then
        echo "Moving existing $WVIEW_CONF_DIR/htmlgen.conf to $WVIEW_CONF_DIR/htmlgen.conf.old..."
        mv $WVIEW_CONF_DIR/htmlgen.conf $WVIEW_CONF_DIR/htmlgen.conf.old
    fi
    echo ""
    echo -n "Writing $WVIEW_CONF_DIR/htmlgen.conf: "
    
    echo "#@" > $WVIEW_CONF_DIR/htmlgen.conf
    echo "#"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "#  This file contains configuration information for the wview htmlgend daemon."  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "#"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "#  Note: For parameters that enable/disable a feature, a value of 0 disables"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "#        the feature and 1 enables it..."  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "#"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo "##################### Station Configuration      #####################"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Station Name:"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "STATION_NAME=$STATION_NAME" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Station City:"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "STATION_CITY=$STATION_CITY" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Station State:"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "STATION_STATE=$STATION_STATE" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    
    
    echo "##################### htmlgend Configuration     #####################"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Where to store generated html and graphics files:"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "IMAGE_PATH=$IMAGE_PATH" >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Where to find HTML template files:"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "HTML_PATH=$HTML_PATH" >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Generation start offset (0-4) in minutes:"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "START_OFFSET=$START_OFFSET" >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# How often to generate (refresh interval for your site data) in minutes:"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "GENERATE_INTERVAL=$GENERATE_INTERVAL" >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Enable metric conversion/units?"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "METRIC_UNITS=$METRIC_UNITS" >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# # If metric, use mm for rain instead of cm?"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "METRIC_USE_RAIN_MM=$METRIC_USE_RAIN_MM" >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Use metric and non-metric units on images?"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "DUAL_UNITS=$DUAL_UNITS" >> $WVIEW_CONF_DIR/htmlgen.conf

    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Store/process VP Plus extended sensor values?"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "EXTENDED_DATA=$EXTENDED_DATA" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# How many archive record browser files to keep (-1 disables, 0 keeps all):"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "ARCHIVE_BROWSER_FILES_TO_KEEP=$ARCHIVE_BROWSER_FILES_TO_KEEP" >> $WVIEW_CONF_DIR/htmlgen.conf
    #echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Moon Phase Text - configure text used for the 'Waxing/Waning %X Full' string"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Moon 'increasing' and 'decreasing' text"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "MPHASE_INCREASE=$MPHASE_INCREASE" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "MPHASE_DECREASE=$MPHASE_DECREASE" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Moon 'full' text"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "MPHASE_FULL=$MPHASE_FULL" >> $WVIEW_CONF_DIR/htmlgen.conf
    #echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Local Radar Image URL (no spaces):"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "LOCAL_RADAR_URL=$LOCAL_RADAR_URL" >> $WVIEW_CONF_DIR/htmlgen.conf
    #echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    
    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# Local Forecast URL (no spaces):"  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "LOCAL_FORECAST_URL=$LOCAL_FORECAST_URL" >> $WVIEW_CONF_DIR/htmlgen.conf

    echo ""  >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# date format (no spaces)" >>  $WVIEW_CONF_DIR/htmlgen.conf
    echo "#            see 'man strftime' for allowable formats." >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "# examples:  %D - US format mm/dd/yy" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "#            %d/%m/%Y  - dd/mm/yyyy" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "#            %x - locale's preferred date representation" >> $WVIEW_CONF_DIR/htmlgen.conf
    echo "DATE_FORMAT=$DATE_FORMAT" >> $WVIEW_CONF_DIR/htmlgen.conf
 
    echo "done!"
    echo ""
    echo ""
} # end of write_html_conf

get_cwop_conf_interactive()
{

    echo "################################################################################"
    echo "--> CWOP Configuration ($WVIEW_CONF_DIR/wvcwop.conf):"
    echo ""
    echo "-------------------------------------------------------------" 
    echo "APRS Call Sign (6 characters, no spaces):"
    echo -n "($APRS_CALL_SIGN): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$APRS_CALL_SIGN" ]; then
            echo "APRS call sign must be specified!"
            exit 10
        fi
    else
        APRS_CALL_SIGN=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- You MUST specify all 3 APRS servers - you can use the same server"
    echo "--Note-- for multiple entries, although this is highly discouraged - "
    echo "--Note-- See http://www.wxqa.com/activecwd.html for a list of servers"
    echo "APRS primary server name (hostname or IP address):"
    echo -n "($APRS_SERVER1): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$APRS_SERVER1" ]; then
            echo "APRS primary server must be specified!"
            exit 10
        fi
    else
        APRS_SERVER1=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "APRS primary port number (usually 23):"
    echo -n "($APRS_PORTNO1): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        APRS_PORTNO1=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "APRS secondary server name (hostname or IP address):"
    echo -n "($APRS_SERVER2): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$APRS_SERVER2" ]; then
            echo "APRS server must be specified!"
            exit 10
        fi
    else
        APRS_SERVER2=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "APRS secondary port number (usually 23):"
    echo -n "($APRS_PORTNO2): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        APRS_PORTNO2=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "APRS tertiary server name (hostname or IP address):"
    echo -n "($APRS_SERVER3): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$APRS_SERVER3" ]; then
            echo "APRS server must be specified!"
            exit 10
        fi
    else
        APRS_SERVER3=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "APRS tertiary port number (usually 23):"
    echo -n "($APRS_PORTNO3): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        APRS_PORTNO3=$INVAL
    fi

    echo ""
    echo "See http://www.topozone.com/viewmaps.asp to get an accurate latitude and"
    echo "longitude for your station location..."

    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- LATITUDE MUST be of the form DDMM.hhd (LORAN format)"
    echo "--Note--   DD   - degrees (always positive and 2 digits)"
    echo "--Note--   MM   - minutes (00 - 59)"
    echo "--Note--   hh   - hundredths of minutes (00 - 99)"
    echo "--Note--   d    - hemisphere indicator (N or S)"
    echo "--Note-- See http://www.topozone.com/viewmaps.asp to get an accurate"
    echo "--Note-- latitude and longitude for your CWOP data"
    echo "Station latitude:"
    echo -n "($LATITUDE): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$LATITUDE" ]; then
            echo "CWOP Latitude must be specified!"
            exit 10
        fi
    else
        LATITUDE=$INVAL
    fi
    
    echo ""
    echo "-------------------------------------------------------------" 
    echo "--Note-- LONGITUDE MUST be of the form DDDMM.hhd (LORAN format)"
    echo "--Note--   DDD  - degrees (always positive and 3 digits)"
    echo "--Note--   MM   - minutes (00 - 59)"
    echo "--Note--   hh   - hundredths of minutes (00 - 99)"
    echo "--Note--   d    - hemisphere indicator (E or W)"
    echo "Station longitude:"
    echo -n "($LONGITUDE): "
    read INVAL
    if [ "" = "$INVAL" ]; then
        if [ "changeME" = "$LONGITUDE" ]; then
            echo "CWOP Longitude must be specified!"
            exit 10
        fi
    else
        LONGITUDE=$INVAL
    fi

    echo ""
    echo "-------------------------------------------------------------" 
    echo "Log the APRS WX packet when sending?"
    echo -n "($LOG_WX_PACKET): "
    read INVAL
    if [ "" != "$INVAL" ]; then
        LOG_WX_PACKET=$INVAL
    fi
} # end of get_cwop_conf_interactive

write_cwop_conf()
{
    # Write out the wvcwop.conf file:
    echo ""
    if [ -f $WVIEW_CONF_DIR/wvcwop.conf ]; then
        echo "Moving existing $WVIEW_CONF_DIR/wvcwop.conf to $WVIEW_CONF_DIR/wvcwop.conf.old..."
        mv $WVIEW_CONF_DIR/wvcwop.conf $WVIEW_CONF_DIR/wvcwop.conf.old
    fi
    echo ""
    echo -n "Writing $WVIEW_CONF_DIR/wvcwop.conf: "
    
    echo "#@" > $WVIEW_CONF_DIR/wvcwop.conf
    echo "#"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "#  This file contains configuration information for the wview CWOP daemon."  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "#"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "#  Note: For parameters that enable/disable a feature, a value of 0 disables"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "#        the feature and 1 enables it..."  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "#"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf
    
    echo "# APRS Call Sign:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "APRS_CALL_SIGN=$APRS_CALL_SIGN" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# APRS Primary Server:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "APRS_SERVER1=$APRS_SERVER1" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# APRS Primary Port Number:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "APRS_PORTNO1=$APRS_PORTNO1" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# APRS Secondary Server:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "APRS_SERVER2=$APRS_SERVER2" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# APRS Secondary Port Number:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "APRS_PORTNO2=$APRS_PORTNO2" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# APRS Tertiary Server:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "APRS_SERVER3=$APRS_SERVER3" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# APRS Tertiary Port Number:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "APRS_PORTNO3=$APRS_PORTNO3" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# CWOP latitude:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "LATITUDE=$LATITUDE" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# CWOP longitude:"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "LONGITUDE=$LONGITUDE" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "# Log APRS WX packets?"  >> $WVIEW_CONF_DIR/wvcwop.conf
    echo "LOG_WX_PACKET=$LOG_WX_PACKET" >> $WVIEW_CONF_DIR/wvcwop.conf
    echo ""  >> $WVIEW_CONF_DIR/wvcwop.conf

    echo "done."
} # end of write_cwop_conf

option_cwop()
{
    if [ -f $WVIEW_CONF_DIR/wvcwop.conf ]; then
        DEFANS=1
    else
        DEFANS=0
    fi
    echo "-------------------------------------------------------------" 
    echo "Enable CWOP (Citizen Weather Observer Program) support?"
    echo -n "($DEFANS): "
    read INVAL
    echo ""
    if [ "" != "$INVAL" ]; then
        DEFANS=$INVAL
    fi

    if [ "1" = "$DEFANS" ]; then
        get_cwop_conf_interactive
        write_cwop_conf
    else
        echo -n "Disabling the CWOP support by naming the config file $WVIEW_CONF_DIR/wvcwop.conf-no-cwop: "
        if [ -f $WVIEW_CONF_DIR/wvcwop.conf ]; then
            mv $WVIEW_CONF_DIR/wvcwop.conf $WVIEW_CONF_DIR/wvcwop.conf-no-cwop
            echo "done."
        elif [ -f $WVIEW_CONF_DIR/wvcwop.conf-no-cwop ]; then
            echo "CWOP support already disabled."
        else
            echo "$WVIEW_CONF_DIR/wvcwop.conf-no-cwop does not exist - thus disabled"
        fi

    fi
} # end of option_cwop

option_http()
{
    if [ -f $WVIEW_CONF_DIR/http.conf ]; then
        DEFANS=1
    else
        DEFANS=0
    fi
    echo "-------------------------------------------------------------"
    echo "--Note-- You MUST enable HTTP (WUNDERGROUND/WEATHERFORYOU) support with '--enable-http' when ./configure was executed..."
    echo "Enable HTTP (WUNDERGROUND/WEATHERFORYOU) support?"
    echo -n "($DEFANS): "
    read INVAL
    echo ""
    if [ "" != "$INVAL" ]; then
        DEFANS=$INVAL
    fi
    
    if [ "1" = "$DEFANS" ]; then
        echo "################################################################################"
        echo "--> HTTP (WUNDERGROUND/WEATHERFORYOU) Configuration ($WVIEW_CONF_DIR/http.conf):"
        echo ""
        echo "-------------------------------------------------------------" 
        echo "WUNDERGROUND Station ID (obtained when you registered with WUNDERGROUND):"
        echo -n "($STATIONID): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$STATIONID" ]; then
                echo "WUNDERGROUND station ID not specified - disabling WUNDERGROUND!"
                STATIONID=0
            fi
        else
            STATIONID=$INVAL
        fi
        
        echo ""
        echo "-------------------------------------------------------------" 
        echo "WUNDERGROUND Password (obtained when you registered with WUNDERGROUND):"
        echo -n "($PASSWORD): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$PASSWORD" ]; then
                echo "WUNDERGROUND password not specified - disabling WUNDERGROUND!"
                STATIONID=0
                PASSWORD=0
            fi
        else
            PASSWORD=$INVAL
        fi
    
        echo ""
        echo "-------------------------------------------------------------" 
        echo "WEATHERFORYOU Station ID (obtained when you registered with WEATHERFORYOU):"
        echo -n "($YOUSTATIONID): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$YOUSTATIONID" ]; then
                echo "WEATHERFORYOU station ID not specified - disabling WEATHERFORYOU!"
                YOUSTATIONID=0
            fi
        else
            YOUSTATIONID=$INVAL
        fi
        
        echo ""
        echo "-------------------------------------------------------------" 
        echo "WEATHERFORYOU Password (obtained when you registered with WEATHERFORYOU):"
        echo -n "($YOUPASSWORD): "
        read INVAL
        if [ "" = "$INVAL" ]; then
            if [ "changeME" = "$YOUPASSWORD" ]; then
                echo "WEATHERFORYOU password not specified - disabling WEATHERFORYOU!"
                YOUSTATIONID=0
                YOUPASSWORD=0
            fi
        else
            YOUPASSWORD=$INVAL
        fi
    
        write_http_conf
    else
        echo -n "Disabling the HTTP (WUNDERGROUND/WEATHERFORYOU) support by naming the config file $WVIEW_CONF_DIR/http.conf-no-http: "
        if [ -f $WVIEW_CONF_DIR/http.conf ]; then
            mv $WVIEW_CONF_DIR/http.conf $WVIEW_CONF_DIR/http.conf-no-http
            echo "done."
        elif [ -f $WVIEW_CONF_DIR/http.conf-no-http ]; then
            echo "HTTP (WUNDERGROUND/WEATHERFORYOU) support already disabled."
        else
            echo "$WVIEW_CONF_DIR/http.conf-no-http does not exist - thus disabled"
        fi
    fi
} # end of option_http

write_http_conf()
{
    # Write out the http.conf file:
    echo ""
    if [ -f $WVIEW_CONF_DIR/http.conf ]; then
        echo "Moving existing $WVIEW_CONF_DIR/http.conf to $WVIEW_CONF_DIR/http.conf.old..."
        mv $WVIEW_CONF_DIR/http.conf $WVIEW_CONF_DIR/http.conf.old
    fi
    echo ""
    echo -n "Writing $WVIEW_CONF_DIR/http.conf: "
    
    echo "#@" > $WVIEW_CONF_DIR/http.conf
    echo "#"  >> $WVIEW_CONF_DIR/http.conf
    echo "#  This file contains configuration information for the wview HTTP (WUNDERGROUND/WEATHERFORYOU) daemon."  >> $WVIEW_CONF_DIR/http.conf
    echo "#"  >> $WVIEW_CONF_DIR/http.conf
    echo "#  Note: For parameters that enable/disable a feature, a value of 0 disables"  >> $WVIEW_CONF_DIR/http.conf
    echo "#        the feature and 1 enables it..."  >> $WVIEW_CONF_DIR/http.conf
    echo "#"  >> $WVIEW_CONF_DIR/http.conf
    echo ""  >> $WVIEW_CONF_DIR/http.conf
    
    echo "# WUNDERGROUND Station ID:"  >> $WVIEW_CONF_DIR/http.conf
    echo "STATIONID=$STATIONID" >> $WVIEW_CONF_DIR/http.conf
    echo ""  >> $WVIEW_CONF_DIR/http.conf

    echo "# WUNDERGROUND password:"  >> $WVIEW_CONF_DIR/http.conf
    echo "PASSWORD=$PASSWORD" >> $WVIEW_CONF_DIR/http.conf
    echo ""  >> $WVIEW_CONF_DIR/http.conf

    echo "# WEATHERFORYOU Station ID:"  >> $WVIEW_CONF_DIR/http.conf
    echo "YOUSTATIONID=$YOUSTATIONID" >> $WVIEW_CONF_DIR/http.conf
    echo ""  >> $WVIEW_CONF_DIR/http.conf

    echo "# WEATHERFORYOU password:"  >> $WVIEW_CONF_DIR/http.conf
    echo "YOUPASSWORD=$YOUPASSWORD" >> $WVIEW_CONF_DIR/http.conf
    echo ""  >> $WVIEW_CONF_DIR/http.conf

    echo "done."
} # end of write_http_conf


option_alarm()
{
    echo ""
    echo "-------------------------------------------------------------"
    if [ -f $WVIEW_CONF_DIR/wvalarm.conf ]; then
        DEFANS=1
    else
        DEFANS=0
    fi
    echo "Run the alarms daemon wvalarmd needed for alarm triggering or data feeds?"
    echo -n "($DEFANS): "
    read INVAL
    echo ""
    if [ "" != "$INVAL" ]; then
        DEFANS=$INVAL
    fi
    
    if [ "1" = "$DEFANS" ]; then
        echo -n "Enabling the alarm daemon by naming the config file $WVIEW_CONF_DIR/wvalarm.conf: "
        if [ -f $WVIEW_CONF_DIR/wvalarm.conf ]; then
            echo "file already exists - wvalarmd is enabled"
            echo "Remember to edit $WVIEW_CONF_DIR/wvalarm.conf if you want to define alarms..."
        elif [ -f $WVIEW_CONF_DIR/wvalarm.conf-no-alarms ]; then
            cp $WVIEW_CONF_DIR/wvalarm.conf-no-alarms $WVIEW_CONF_DIR/wvalarm.conf
            echo "done."
            echo "Remember to edit $WVIEW_CONF_DIR/wvalarm.conf if you want to define alarms..."
        else
            echo "The default (and disabled) distro file $WVIEW_CONF_DIR/wvalarm.conf-no-alarms does not exist!"
            echo "Did you use the install-env make target or copy the file manually?"
            echo "Alarms will be disabled until you copy the config files from the distro and re-run this script..."
        fi
    else
        echo -n "Disabling the alarm daemon by naming the config file $WVIEW_CONF_DIR/wvalarm.conf-no-alarms: "
        if [ -f $WVIEW_CONF_DIR/wvalarm.conf ]; then
            mv $WVIEW_CONF_DIR/wvalarm.conf $WVIEW_CONF_DIR/wvalarm.conf-no-alarms
            echo "done."
        elif [ -f $WVIEW_CONF_DIR/wvalarm.conf-no-alarms ]; then
            echo "wvalarmd already disabled."
        else
            echo "$WVIEW_CONF_DIR/wvalarm.conf-no-alarms does not exist - thus disabled"
        fi
    fi
} # end of option_alarm

option_ftp()
{
    echo ""
    echo "-------------------------------------------------------------" 
    if [ -f $WVIEW_CONF_DIR/wviewftp.conf ]; then
        DEFANS=1
    else
        DEFANS=0
    fi
    echo "--Note-- Only needed if you plan to ftp your generated files to a remote web server or ISP account..."
    echo "Run the ftp daemon wviewftpd?"
    echo -n "($DEFANS): "
    read INVAL
    echo ""
    if [ "" != "$INVAL" ]; then
        DEFANS=$INVAL
    fi
    
    if [ "1" = "$DEFANS" ]; then
        USEFTP=1
        echo -n "Enabling the ftp daemon by naming the config file $WVIEW_CONF_DIR/wviewftp.conf: "
        if [ -f $WVIEW_CONF_DIR/wviewftp.conf ]; then
            echo "file already exists - wviewftpd is enabled"
            echo "Remember to edit $WVIEW_CONF_DIR/wviewftp.conf to define files to transfer..."
        elif [ -f $WVIEW_CONF_DIR/wviewftp.conf-no-ftp ]; then
            cp $WVIEW_CONF_DIR/wviewftp.conf-no-ftp $WVIEW_CONF_DIR/wviewftp.conf
            echo "done."
            echo "Remember to edit $WVIEW_CONF_DIR/wviewftp.conf to define files to transfer..."
        else
            echo "The default (and disabled) distro file $WVIEW_CONF_DIR/wviewftp.conf-no-ftp does not exist!"
            echo "Did you use the install-env make target or copy the file manually?"
            echo "FTP will be disabled until you copy the config files from the distro and re-run this script..."
        fi
    else
        USEFTP=0
        echo -n "Disabling the ftp daemon by naming the config file $WVIEW_CONF_DIR/wviewftp.conf-no-ftp: "
        if [ -f $WVIEW_CONF_DIR/wviewftp.conf ]; then
            mv $WVIEW_CONF_DIR/wviewftp.conf $WVIEW_CONF_DIR/wviewftp.conf-no-ftp
            echo "done."
        elif [ -f $WVIEW_CONF_DIR/wviewftp.conf-no-ftp ]; then
            echo "wviewftpd already disabled."
        else
            echo "$WVIEW_CONF_DIR/wviewftp.conf-no-ftp does not exist - thus disabled"
        fi
    fi
} # end of option_ftp

option_ssh()
{
    if [ "1" != "$USEFTP" ]; then
        echo ""
        echo "-------------------------------------------------------------" 
        if [ -f $WVIEW_CONF_DIR/wviewssh.conf ]; then
            DEFANS=1
        else
            DEFANS=0
        fi
        echo "--Note-- Only needed if you plan to synchronize your generated files with a remote web server or ISP account..."
        echo "Run the rsync/ssh daemon wviewsshd?"
        echo -n "($DEFANS): "
        read INVAL
        echo ""
        if [ "" != "$INVAL" ]; then
            DEFANS=$INVAL
        fi
    
        if [ "1" = "$DEFANS" ]; then
            echo -n "Enabling the rsync/ssh daemon by naming the config file $WVIEW_CONF_DIR/wviewssh.conf: "
            if [ -f $WVIEW_CONF_DIR/wviewssh.conf ]; then
                echo "file already exists - wviewsshd is enabled"
                echo "Remember to edit $WVIEW_CONF_DIR/wviewssh.conf to define sync directories..."
            elif [ -f $WVIEW_CONF_DIR/wviewssh.conf-no-ssh ]; then
                cp $WVIEW_CONF_DIR/wviewssh.conf-no-ssh $WVIEW_CONF_DIR/wviewssh.conf
                echo "done."
                echo "Remember to edit $WVIEW_CONF_DIR/wviewssh.conf to define sync directories..."
            else
                echo "The default (and disabled) distro file $WVIEW_CONF_DIR/wviewssh.conf-no-ssh does not exist!"
                echo "Did you use the install-env make target or copy the file manually?"
                echo "rsync/ssh will be disabled until you copy the config files from the distro and re-run this script..."
            fi
        else
            echo -n "Disabling the rsync/ssh daemon by naming the config file $WVIEW_CONF_DIR/wviewssh.conf-no-ssh: "
            if [ -f $WVIEW_CONF_DIR/wviewssh.conf ]; then
                mv $WVIEW_CONF_DIR/wviewssh.conf $WVIEW_CONF_DIR/wviewssh.conf-no-ssh
                echo "done."
            elif [ -f $WVIEW_CONF_DIR/wviewssh.conf-no-ssh ]; then
                echo "wviewsshd already disabled."
            else
                echo "$WVIEW_CONF_DIR/wviewssh.conf-no-ssh does not exist - thus disabled"
            fi
        fi
    fi
} # end of option_ssh

option_forecast()
{
    # VantagePro Only
    if [ "$STATION_TYPE" = "VantagePro" ]; then
        echo ""
        echo "-------------------------------------------------------------" 
        if [ -f $WVIEW_CONF_DIR/forecast.conf ]; then
            DEFANS=1
        else
            DEFANS=0
        fi
        echo "--Note-- This will require 35 KB or more of memory..."
        echo "Enable the Vantage Pro Forecast icon support and Forecast Rule text support?"
        echo -n "($DEFANS): "
        read INVAL
        echo ""
        if [ "" != "$INVAL" ]; then
            DEFANS=$INVAL
        fi
        
        if [ "1" = "$DEFANS" ]; then
            echo -n "Enabling the forecast processing by naming the config file $WVIEW_CONF_DIR/forecast.conf: "
            if [ -f $WVIEW_CONF_DIR/forecast.conf ]; then
                echo "file already exists - forecast processing is enabled"
                echo "Remember to edit $WVIEW_CONF_DIR/forecast.conf to define icons and text..."
            elif [ -f $WVIEW_CONF_DIR/forecast.conf-no-forecast ]; then
                cp $WVIEW_CONF_DIR/forecast.conf-no-forecast $WVIEW_CONF_DIR/forecast.conf
                echo "done."
                echo "Remember to edit $WVIEW_CONF_DIR/forecast.conf to define icons and text..."
            else
                echo "The default (and disabled) distro file $WVIEW_CONF_DIR/forecast.conf-no-forecast does not exist!"
                echo "Did you use the install-env make target or copy the file manually?"
                echo "forecast processing will be disabled until you copy the config files from the distro and re-run this script..."
            fi
        else
            echo -n "Disabling the forecast processing by naming the config file $WVIEW_CONF_DIR/forecast.conf-no-forecast: "
            if [ -f $WVIEW_CONF_DIR/forecast.conf ]; then
                mv $WVIEW_CONF_DIR/forecast.conf $WVIEW_CONF_DIR/forecast.conf-no-forecast
                echo "done."
            elif [ -f $WVIEW_CONF_DIR/forecast.conf-no-forecast ]; then
                echo "forecast processing already disabled."
            else
                echo "$WVIEW_CONF_DIR/forecast.conf-no-forecast does not exist - thus disabled"
            fi
        fi
    fi
    if [ "$STATION_TYPE" != "VantagePro" ]; then
        if [ -f $WVIEW_CONF_DIR/forecast.conf ]; then
            mv $WVIEW_CONF_DIR/forecast.conf $WVIEW_CONF_DIR/forecast.conf-no-forecast
        fi
    fi
} # end of option_forecast


################################################################################
##################  S C R I P T  E X E C U T I O N  S T A R T  #################
################################################################################

# First test to make sure that wview is not running for interactive and set...
if [ -f $WVIEWD_PID -a "$1" != "get" ]; then
    echo "wviewd is running - stop wview before running this script..."
    exit 3
fi

METHOD=$1
SET_FILE=$2

if [ "$METHOD" = "" ]   # run interactively
then
    interactive_intro
    get_current
    set_default
    get_wview_conf_interactive
    write_wview_conf
    get_html_conf_interactive
    write_html_conf

    echo "################################################################################"
    echo "--> Optional wview Components"
    echo ""
    echo ""

    option_cwop
    option_http
    option_alarm
    option_ftp
    option_ssh
    option_forecast

echo ""
echo ""
echo "################################################################################"
echo "--> wview Configuration Complete!"
echo "################################################################################"
else
    case "$METHOD" in
        "get" )
            get_current
            set_default
            print_current
            ;;
        "set" )
            if [ "$SET_FILE" = "" ]; then
                echo "set requires a source file:"
                show_usage
                exit 1
            fi
            if [ ! -f $SET_FILE ]; then
                echo "source path $SET_FILE does not exist"
                show_usage
                exit 1
            fi

            get_current
            set_default
            write_wview_conf
            write_html_conf
            ;;
        *)
            echo "$METHOD not supported"
            show_usage
            exit 1
            ;;
    esac
fi

exit 0

