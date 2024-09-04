class CsvExportService
  def initialize(users)
    @users = users
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      add_csv_headers(csv)
      @users.find_each do |user|
        csv << generate_user_row(user)
      end
    end
  end

  def generate_csv_for_user
    @user = @users # change of variable because here we have only one user
    CSV.generate(headers: true) do |csv|
      add_csv_headers(csv)
      csv << generate_user_row(@user)
    end
  end

  private

  def add_csv_headers(csv)
    csv << ['ID', 'First Name', 'Last Name', 'Email', 'Gender', 'Hobbies', 'Addresses']
  end

  def generate_user_row(user)
    default_address = user.addresses.find(&:default?)

    address = if default_address
                [
                  default_address.plot_no,
                  default_address.society_name,
                  default_address.pincode,
                  default_address.state.name,
                  default_address.city.name
                ].join(', ')
              else
                ''
              end
    [
      user.id,
      user.first_name,
      user.last_name,
      user.email,
      user.gender,
      user.hobbies.join(', '),
      if address == ''
        nil
      else
        address
      end
    ]
  end
end
