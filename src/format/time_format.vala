namespace Ginko.Format {

public class TimeFormat {
    public string format(TimeVal time) {
        var datetime = new DateTime.from_unix_utc(time.tv_sec);
        return datetime.format("%d.%m.%Y %H:%M");
    }
}
    
}
