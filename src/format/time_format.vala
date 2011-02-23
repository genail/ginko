namespace Ginko.Format {

public class TimeFormat {
    public string format(TimeVal p_time) {
        var datetime = new DateTime.from_unix_utc(p_time.tv_sec);
        return datetime.format("%d.%m.%Y %H:%M");
    }
}
    
}
